const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: i32 };
const Cell = enum { block, walked, free };

const Map = struct {
    blocks: []Cell,
    n: usize,

    pub fn get(self: *const Map, x: i32, y: i32) Cell {
        return self.blocks[@as(usize, @intCast(x)) * self.n + @as(usize, @intCast(y))];
    }

    pub fn set(self: *const Map, x: i32, y: i32, cell: Cell) void {
        self.blocks[@as(usize, @intCast(x)) * self.n + @as(usize, @intCast(y))] = cell;
    }

    pub fn contains(self: *const Map, x: i32, y: i32) bool {
        return x >= 0 and y >= 0 and x < self.n and y < self.n;
    }
};

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');
    // input is a square
    const n = iter.peek().?.len;
    const map = Map{
        .blocks = try this.allocator.alloc(Cell, n * n),
        .n = n,
    };
    defer this.allocator.free(map.blocks);

    var x: i32 = 0;
    var start_x: i32 = 0;
    var start_y: i32 = 0;
    while (iter.next()) |line| {
        if (line.len == 0) break;
        for (line, 0..) |char, y| {
            switch (char) {
                '#' => map.set(x, @intCast(y), Cell.block),
                '^' => {
                    start_x = x;
                    start_y = @intCast(y);
                },
                else => {},
            }
        }
        x += 1;
    }
    return Solution{ .p1 = part1(map, start_x, start_y), .p2 = start_y };
}

fn part1(map: Map, sx: i32, sy: i32) u32 {
    // guard starts going up
    var dx: i8 = -1;
    var dy: i8 = 0;
    var x = sx;
    var y = sy;
    var count: u32 = 0;
    while (true) {
        // std.debug.print("guard at {d},{d}\n", .{ x, y });
        const xx = x + dx;
        const yy = y + dy;
        if (!map.contains(xx, yy)) break;
        switch (map.get(xx, yy)) {
            .block => {
                // rotate 90 deg clockwise (or counter because my basis is wrongly oriented...)
                const tmp = dx;
                dx = dy;
                dy = -tmp;
            },
            .free => {
                x = xx;
                y = yy;
                count += 1;
                map.set(xx, yy, Cell.walked);
            },
            .walked => {
                x = xx;
                y = yy;
            },
        }
    }
    return count;
}

test "sample" {
    const input =
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(41, sol.p1);
    // try std.testing.expectEqual(123, sol.p2);
}
