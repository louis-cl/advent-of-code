const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u64, p2: u64 };

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');
    var rhs = try this.allocator.alloc(u64, 30); // there is no way we backtrack 30 elements
    defer this.allocator.free(rhs);

    var p1: u64 = 0;
    var p2: u64 = 0;
    while (iter.next()) |line| {
        if (line.len == 0) break;
        const lhs = consumeInt(line).?;
        var pending = lhs.rest[2..];
        var i: usize = 0;
        while (consumeInt(pending)) |res| {
            rhs[i] = res.val;
            i += 1;
            if (res.rest.len < 1) break;
            pending = res.rest[1..];
        }
        // std.debug.print("{d} to '{any}'\n", .{ lhs.val, rhs[0..i] });
        if (canSolvePart1(lhs.val, rhs[0..i])) {
            p1 += lhs.val;
            p2 += lhs.val;
        } else if (canSolvePart2(lhs.val, rhs[0..i])) p2 += lhs.val;
    }
    return Solution{ .p1 = p1, .p2 = p2 };
}

// try @mod/@rem and other div operations that may
fn canSolvePart1(lhs: u64, rhs: []const u64) bool {
    if (rhs.len == 1) return lhs == rhs[0];
    const x = rhs[rhs.len - 1];
    const rest = rhs[0 .. rhs.len - 1];
    if (lhs > x and canSolvePart1(lhs - x, rest)) return true;
    if (lhs % x == 0 and canSolvePart1(lhs / x, rest)) return true;
    return false;
}

fn canSolvePart2(lhs: u64, rhs: []const u64) bool {
    if (rhs.len == 1) return lhs == rhs[0];
    const x = rhs[rhs.len - 1];
    const rest = rhs[0 .. rhs.len - 1];
    if (lhs > x and canSolvePart2(lhs - x, rest)) return true;
    if (lhs % x == 0 and canSolvePart2(lhs / x, rest)) return true;
    var pow: u64 = 10;
    while (pow <= x) pow *= 10;
    if (lhs % pow == x and canSolvePart2(lhs / pow, rest)) return true;
    return false;
}

fn consumeInt(buf: []const u8) ?struct { rest: []const u8, val: u64 } {
    var r: u64 = 0;
    var i: usize = 0;
    while (i < buf.len and std.ascii.isDigit(buf[i])) : (i += 1)
        r = 10 * r + buf[i] - '0';
    if (i == 0) return null;
    return .{ .rest = buf[i..], .val = r };
}

test "sample" {
    const input =
        \\190: 10 19
        \\3267: 81 40 27
        \\83: 17 5
        \\156: 15 6
        \\7290: 6 8 6 15
        \\161011: 16 10 13
        \\192: 17 8 14
        \\21037: 9 7 18 13
        \\292: 11 6 16 20
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(3749, sol.p1);
    try std.testing.expectEqual(11387, sol.p2);
}
