const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u64 };

pub fn solve(this: *const @This()) !Solution {
    var line_it = mem.splitScalar(u8, this.input, '\n');
    var p1: u32 = 0;
    while (line_it.next()) |line| {
        if (line.len == 0) continue;

        var numbers = std.ArrayList(i32).init(this.allocator);
        defer numbers.deinit();
        var number_it = mem.splitScalar(u8, line, ' ');
        while (number_it.next()) |n| {
            try numbers.append(try std.fmt.parseInt(i32, n, 10));
        }

        if (isSafe(numbers.items)) p1 += 1;
    }
    return Solution{ .p1 = p1, .p2 = 0 };
}

fn isSafe(nums: []const i32) bool {
    var previous = nums[0];
    const up = nums[1] - previous;
    for (nums[1..]) |n| {
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
    // try std.testing.expectEqual(0, sol.p2);
}
