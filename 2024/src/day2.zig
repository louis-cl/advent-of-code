const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u64 };

pub fn solve(this: *const @This()) !Solution {
    var line_it = mem.splitScalar(u8, this.input, '\n');
    var safe: u32 = 0;
    while (line_it.next()) |line| {
        if (line.len == 0) continue;
        var number_it = mem.splitScalar(u8, line, ' ');
        const first = try int(number_it.first());
        const second = try int(number_it.peek().?);
        if (first == second) continue;
        const up = first < second;
        var previous = first;
        var line_safe = true;
        while (number_it.next()) |next| {
            const n = try int(next);
            if (up) {
                line_safe = previous + 1 <= n and n <= previous + 3;
            } else {
                line_safe = previous - 1 >= n and n >= previous - 3;
            }
            if (!line_safe) break;
            previous = n;
        }
        if (line_safe) safe += 1;
    }
    return Solution{ .p1 = safe, .p2 = 0 };
}

fn int(num: []const u8) !i32 {
    return try std.fmt.parseInt(i32, num, 10);
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
