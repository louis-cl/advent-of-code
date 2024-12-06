const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u32 };
const Cell = enum { block, walked, free };
const State = struct {
    x: i32,
    y: i32,
    dx: i8,
    dy: i8,
    fn next(self: *const State) State {
        return State{ .x = self.x + self.dx, .y = self.y + self.dy, .dx = self.dx, .dy = self.dy };
    }
    fn turn(self: *const State) State {
        // rotate 90 deg clockwise (or counter because my basis is wrongly oriented...)
        return State{ .x = self.x, .y = self.y, .dx = self.dy, .dy = -self.dx };
    }
};

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
    var start: State = undefined;
    while (iter.next()) |line| {
        if (line.len == 0) break;
        for (line, 0..) |char, y| {
            switch (char) {
                '#' => map.set(x, @intCast(y), Cell.block),
                '^' => {
                    start = State{ .x = x, .y = @intCast(y), .dx = -1, .dy = 0 };
                },
                else => {},
            }
        }
        x += 1;
    }
    return Solution{
        .p1 = part1(map, start),
        .p2 = part2(this.allocator, map, start),
        // .p2 = 0,
    };
}

fn part1(map: Map, start: State) u32 {
    var p = start;
    var count: u32 = 0;
    while (true) {
        // std.debug.print("guard at {d},{d}\n", .{ x, y });
        const next = p.next();
        if (!map.contains(next.x, next.y)) break;
        switch (map.get(next.x, next.y)) {
            .block => p = p.turn(),
            .free => {
                p = next;
                count += 1;
                map.set(p.x, p.y, Cell.walked);
            },
            .walked => p = next,
        }
    }
    return count;
}

fn part2(allocator: mem.Allocator, map: Map, start: State) u32 {
    var p = start;
    var rocks = std.AutoHashMap([2]i32, void).init(allocator);
    defer rocks.deinit();
    while (true) {
        // std.debug.print("guard at {d},{d}\n", .{ p.x, p.y });
        const next = p.next();
        if (!map.contains(next.x, next.y)) break;
        switch (map.get(next.x, next.y)) {
            .block => p = p.turn(),
            .free, .walked => {
                // try a rock
                if (!(next.x == start.x and next.y == start.y) and !rocks.contains(.{ next.x, next.y })) { // don't put on start
                    // std.debug.print("try rock at {d},{d}\n", .{ next.x, next.y });
                    map.set(next.x, next.y, Cell.block);
                    if (cycles(allocator, map, start)) rocks.put(.{ next.x, next.y }, {}) catch unreachable;
                    map.set(next.x, next.y, Cell.walked); // undo, cell doesn't matter
                }
                p = next;
            },
        }
    }
    return rocks.count();
}

fn cycles(allocator: mem.Allocator, map: Map, start: State) bool {
    var p = start;
    var visited = std.AutoHashMap(State, void).init(allocator);
    defer visited.deinit();
    while (!visited.contains(p)) {
        // std.debug.print("\tCYCLE, guard at {d},{d}\n", .{ p.x, p.y });
        visited.put(p, {}) catch unreachable;
        const next = p.next();
        if (!map.contains(next.x, next.y)) return false;
        switch (map.get(next.x, next.y)) {
            .block => p = p.turn(),
            .free, .walked => p = next,
        }
    }
    return true;
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
    try std.testing.expectEqual(6, sol.p2);
}
