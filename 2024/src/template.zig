const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u32 };

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) break;
    }
    return Solution{ .p1 = 0, .p2 = 0 };
}

test "sample" {
    const input =
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(143, sol.p1);
    // try std.testing.expectEqual(123, sol.p2);
}
