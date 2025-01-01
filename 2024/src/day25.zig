const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: usize, p2: []const u8 };

const vec5 = @Vector(5, u4);

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');
    var keys = std.ArrayList(vec5).init(this.allocator);
    var locks = std.ArrayList(vec5).init(this.allocator);
    defer keys.deinit();
    defer locks.deinit();

    while (iter.next()) |line| {
        if (line.len == 0) continue; // skip empty line
        var pins: vec5 = @splat(0);
        var pin_line = iter.next().?;
        for (0..5) |_| {
            for (pin_line, 0..) |c, i| {
                if (c == '#') pins[i] = pins[i] + 1;
            }
            pin_line = iter.next().?;
        }
        // std.debug.print("read {any}\n", .{pins});
        if (pin_line[0] == '#') {
            try keys.append(pins);
        } else {
            try locks.append(pins);
        }
    }

    var p1: usize = 0;
    const limit: vec5 = @splat(5);
    for (keys.items) |key| {
        for (locks.items) |lock| {
            const check = (key + lock) <= limit;
            if (@reduce(.And, check)) p1 += 1;
        }
    }
    return Solution{ .p1 = p1, .p2 = "n/a" };
}

test "sample" {
    const input =
        \\#####
        \\.####
        \\.####
        \\.####
        \\.#.#.
        \\.#...
        \\.....
        \\
        \\#####
        \\##.##
        \\.#.##
        \\...##
        \\...#.
        \\...#.
        \\.....
        \\
        \\.....
        \\#....
        \\#....
        \\#...#
        \\#.#.#
        \\#.###
        \\#####
        \\
        \\.....
        \\.....
        \\#.#..
        \\###..
        \\###.#
        \\###.#
        \\#####
        \\
        \\.....
        \\.....
        \\.....
        \\#....
        \\#.#..
        \\#.#.#
        \\#####
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(3, sol.p1);
    // try std.testing.expectEqual(123, sol.p2);
}
