const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: i64, p2: i64 };

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

    // part 1
    var total: u32 = 0;
    for (left.items, right.items) |l, r| {
        total += @abs(l - r);
    }

    // part 2
    var left_nums = std.AutoHashMap(i32, i32).init(this.allocator);
    defer left_nums.deinit();
    for (left.items) |l| {
        const count = left_nums.get(l) orelse 0;
        try left_nums.put(l, count + 1);
    }

    var sim: i64 = 0;
    for (right.items) |r| {
        if (left_nums.get(r)) |c| {
            sim += r * c;
        }
    }

    return Solution{ .p1 = total, .p2 = sim };
}

// test "it does p1 one line" {
//     const problem: @This() = .{
//         .input = "3   4\n",
//         .allocator = std.testing.allocator,
//     };

//     try std.testing.expectEqual(1, try problem.part1());
// }

// test "p2 sample" {
//     const input =
//         \\3   4
//         \\4   3
//         \\2   5
//         \\1   3
//         \\3   9
//         \\3   3
//         \\
//     ;
//     const problem: @This() = .{
//         .input = input,
//         .allocator = std.testing.allocator,
//     };

//     try std.testing.expectEqual(31, try problem.part2());
// }
