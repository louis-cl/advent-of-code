const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: i64, p2: u64 };

pub fn solve(this: *const @This()) !Solution {
    var line_it = mem.splitScalar(u8, this.input, '\n');
    var left = std.ArrayList(i32).init(this.allocator);
    defer left.deinit();
    var right = std.ArrayList(i32).init(this.allocator);
    defer right.deinit();
    while (line_it.next()) |line| {
        if (line.len == 0) continue;
        var number_it = mem.splitSequence(u8, line, "   ");
        const l = try std.fmt.parseInt(i32, number_it.first(), 10);
        try left.append(l);
        const r = try std.fmt.parseInt(i32, number_it.next().?, 10);
        try right.append(r);
    }
    std.mem.sort(i32, left.items, {}, std.sort.asc(i32));
    std.mem.sort(i32, right.items, {}, std.sort.asc(i32));

    return Solution{ .p1 = part1(left.items, right.items), .p2 = part2(left.items, right.items) };
}

fn part1(left: []i32, right: []i32) i64 {
    var total: u32 = 0;
    for (left, right) |l, r| {
        total += @abs(l - r);
    }
    return total;
}

fn part2(left: []i32, right: []i32) u64 {
    var i: u64 = 0; // left item
    var j: u64 = 0; // right item
    var total: u64 = 0;
    while (i < left.len) {
        const l = left[i];
        // find first on the right
        while (j < right.len and right[j] < l) j += 1;
        if (j == right.len) break;
        // runs
        const left_run = run(left[i..]);
        i += left_run;
        if (right[j] != l) continue;
        const right_run = run(right[j..]);
        j += right_run;
        total += right_run * left_run * @as(u64, @intCast(l));
    }
    return total;
}

fn run(arr: []i32) u64 {
    var k: u64 = 1;
    while (k < arr.len and arr[k] == arr[0]) k += 1;
    return k;
}

test "it does p1 one line" {
    const problem: @This() = .{
        .input = "3   4\n",
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();

    try std.testing.expectEqual(1, sol.p1);
}

test "sample" {
    const input =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(11, sol.p1);
    try std.testing.expectEqual(31, sol.p2);
}
