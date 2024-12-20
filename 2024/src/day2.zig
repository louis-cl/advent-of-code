const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u64 };

fn parseInt(buf: []const u8) i32 {
    var r: i32 = buf[0] - '0';
    if (buf.len > 1) {
        r = 10 * r + buf[1] - '0';
    }
    return r;
}

pub fn solve(this: *const @This()) !Solution {
    var line_it = mem.splitScalar(u8, this.input, '\n');
    var p1: u32 = 0;
    var p2: u32 = 0;
    while (line_it.next()) |line| {
        if (line.len == 0) continue;

        var buff: [8]i32 = undefined;
        var len: usize = 0;
        var number_it = mem.splitScalar(u8, line, ' ');
        while (number_it.next()) |n| {
            buff[len] = parseInt(n);
            len += 1;
        }

        const numbers = buff[0..len];

        if (isSafe(numbers, 0)) {
            p1 += 1;
            p2 += 1;
        } else {
            if (isSafe(numbers[1..], 0)) {
                p2 += 1; // skip first element
            } else {
                // skip any other element
                for (1.., numbers[1..]) |i, _| {
                    if (isSafe(numbers, i)) {
                        p2 += 1;
                        break;
                    }
                }
            }
        }
    }
    return Solution{ .p1 = p1, .p2 = p2 };
}

fn isSafe(nums: []const i32, skip: usize) bool {
    var previous = nums[0];
    const up = if (skip == 1) nums[2] - previous else nums[1] - previous;
    for (nums[1..], 1..) |n, i| {
        if (i == skip) continue;
        const diff = n - previous;
        if (@abs(diff) < 1 or @abs(diff) > 3 or up * diff < 0) return false;
        previous = n;
    }
    return true;
}

test "sample" {
    const input =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(2, sol.p1);
    try std.testing.expectEqual(4, sol.p2);
}
