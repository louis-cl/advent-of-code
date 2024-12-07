const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: i64, p2: u32 };

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');
    var rhs = try this.allocator.alloc(i64, 30); // there is no way we backtrack 30 elements
    defer this.allocator.free(rhs);

    var p1: i64 = 0;
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
        if (canSolve(0, lhs.val, rhs[0..i])) p1 += lhs.val;
    }
    return Solution{ .p1 = p1, .p2 = 0 };
}

fn canSolve(partial: i64, lhs: i64, rhs: []const i64) bool {
    if (rhs.len == 0) return partial == lhs;
    if (partial > lhs) return false;
    return canSolve(partial + rhs[0], lhs, rhs[1..]) or canSolve(partial * rhs[0], lhs, rhs[1..]);
}

fn consumeInt(buf: []const u8) ?struct { rest: []const u8, val: i64 } {
    var r: i64 = 0;
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
    // try std.testing.expectEqual(123, sol.p2);
}
