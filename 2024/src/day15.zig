const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: usize, p2: usize };
const Cell = enum { free, wall, box };
const Cell2 = enum { free, wall, boxleft, boxright };
const vec2 = @Vector(2, i16);

const Part1 = struct {
    map: []Cell,
    n: usize,
    robot: vec2,
    fn at(self: *@This(), i: usize, j: usize) *Cell {
        return &self.map[i * self.n + j];
    }
    fn move(self: *@This(), dir: vec2) void {
        const next = self.robot + dir;
        if (self.push(next, dir, .free)) {
            self.robot = next;
        }
    }
    fn push(self: *@This(), pos: vec2, dir: vec2, pushed: Cell) bool {
        // std.debug.print("pushing {any} to {any}\n", .{ pushed, pos });
        const cell = self.at(@intCast(pos[0]), @intCast(pos[1]));
        switch (cell.*) {
            .wall => return false,
            .free => {
                cell.* = pushed;
                return true;
            },
            .box => {
                if (self.push(pos + dir, dir, .box)) {
                    cell.* = pushed;
                    return true;
                }
                return false;
            },
        }
    }
    fn result(self: *@This()) usize {
        var total: usize = 0;
        for (1..self.n - 1) |i| {
            for (1..self.n - 1) |j| {
                if (self.at(i, j).* == .box) {
                    total += 100 * i + j;
                }
            }
        }
        return total;
    }

    fn print(self: *@This()) void {
        for (0..self.n) |i| {
            for (0..self.n) |j| {
                const c: u8 = switch (self.at(i, j).*) {
                    .free => '.',
                    .wall => '#',
                    .box => 'O',
                };
                std.debug.print("{c}", .{c});
            }
            std.debug.print("\n", .{});
        }
    }
};

const Part2 = struct {
    map: []Cell2,
    width: usize,
    height: usize,
    robot: vec2,
    fn at(self: *@This(), i: usize, j: usize) *Cell2 {
        return &self.map[i * self.width + j];
    }
    fn atP(self: *@This(), p: vec2) *Cell2 {
        return self.at(@intCast(p[0]), @intCast(p[1]));
    }
    fn move(self: *@This(), dir: vec2) void {
        const next = self.robot + dir;
        if (dir[0] == 0) {
            if (self.pushH(next, dir, .free)) {
                self.robot = next;
            }
        } else if (self.canPushV(next, dir)) {
            self.pushV(next, dir, .free);
            self.robot = next;
        }
    }
    fn pushH(self: *@This(), pos: vec2, dir: vec2, pushed: Cell2) bool {
        const cell = self.atP(pos);
        // std.debug.print("pushingH {any} pushing to {any} found {any}\n", .{ pushed, pos, cell.* });
        switch (cell.*) {
            .wall => return false,
            .free => {
                cell.* = pushed;
                return true;
            },
            .boxleft, .boxright => {
                if (self.pushH(pos + dir, dir, cell.*)) {
                    cell.* = pushed;
                    return true;
                }
                return false;
            },
        }
    }
    fn canPushV(self: *@This(), pos: vec2, dir: vec2) bool {
        return switch (self.atP(pos).*) {
            .wall => false,
            .free => true,
            .boxleft => self.canPushV(pos + dir, dir) and self.canPushV(pos + dir + vec2{ 0, 1 }, dir),
            .boxright => self.canPushV(pos + dir, dir) and self.canPushV(pos + dir + vec2{ 0, -1 }, dir),
        };
    }
    fn pushV(self: *@This(), pos: vec2, dir: vec2, pushed: Cell2) void {
        // std.debug.print("pushingV {any} to {any}\n", .{ pushed, pos });
        const cell = self.atP(pos);
        switch (cell.*) {
            .wall => unreachable, // canPushV guarantees this
            .free => {},
            .boxleft => {
                self.pushV(pos + dir, dir, .boxleft);
                cell.* = .free; // prevent matches from the other side
                self.pushV(pos + vec2{ 0, 1 }, dir, .free);
            },
            .boxright => {
                self.pushV(pos + dir, dir, .boxright);
                cell.* = .free; // prevent matches from the other side
                self.pushV(pos + vec2{ 0, -1 }, dir, .free);
            },
        }
        cell.* = pushed;
    }
    fn result(self: *@This()) usize {
        var total: usize = 0;
        for (1..self.height - 1) |i| {
            for (2..self.width - 2) |j| {
                if (self.at(i, j).* == .boxleft) {
                    total += 100 * i + j;
                }
            }
        }
        return total;
    }
    fn print(self: *@This()) void {
        for (0..self.height) |i| {
            for (0..self.width) |j| {
                if (std.meta.eql(self.robot, vec2{ @intCast(i), @intCast(j) })) {
                    std.debug.print("@", .{});
                    continue;
                }
                const c: u8 = switch (self.at(i, j).*) {
                    .free => '.',
                    .wall => '#',
                    .boxleft => '[',
                    .boxright => ']',
                };
                std.debug.print("{c}", .{c});
            }
            std.debug.print("\n", .{});
        }
    }
};

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');

    // parse map
    const n = iter.peek().?.len; // square map
    var part1 = Part1{ .map = try this.allocator.alloc(Cell, n * n), .n = n, .robot = @splat(0) };
    defer this.allocator.free(part1.map);
    var i: usize = 0;
    while (iter.next()) |line| {
        if (line.len == 0) break; // done with map
        std.debug.assert(line.len == n);
        for (line, 0..) |c, j| {
            switch (c) {
                '#' => part1.at(i, j).* = Cell.wall,
                '.' => part1.at(i, j).* = Cell.free,
                'O' => part1.at(i, j).* = Cell.box,
                '@' => {
                    part1.at(i, j).* = Cell.free;
                    part1.robot = vec2{ @intCast(i), @intCast(j) };
                },
                else => unreachable,
            }
        }
        i += 1;
    }
    std.debug.assert(i == n);
    std.debug.assert(part1.robot[0] != 0);

    // expand map for part2
    const n2 = 2 * n;
    var part2 = Part2{
        .map = try this.allocator.alloc(Cell2, n * n2), //
        .height = n,
        .width = n2, // sizes
        .robot = part1.robot * vec2{ 1, 2 },
    };
    defer this.allocator.free(part2.map);
    expandMap(part2.map, part1.map, n);

    // process instructions
    while (iter.next()) |line| {
        for (line) |c| {
            const dir = switch (c) {
                '<' => vec2{ 0, -1 },
                '>' => vec2{ 0, 1 },
                '^' => vec2{ -1, 0 },
                'v' => vec2{ 1, 0 },
                else => unreachable,
            };
            // std.debug.print("DIR {c}\n", .{c});
            // part2.print();
            part1.move(dir);
            part2.move(dir);
        }
    }
    return Solution{ .p1 = part1.result(), .p2 = part2.result() };
}

fn expandMap(map2: []Cell2, map: []Cell, n: usize) void {
    for (0..n) |i| {
        for (0..n) |j| {
            const z = i * 2 * n + 2 * j;
            switch (map[i * n + j]) {
                .free => {
                    map2[z] = Cell2.free;
                    map2[z + 1] = Cell2.free;
                },
                .wall => {
                    map2[z] = Cell2.wall;
                    map2[z + 1] = Cell2.wall;
                },
                .box => {
                    map2[z] = Cell2.boxleft;
                    map2[z + 1] = Cell2.boxright;
                },
            }
        }
    }
}

test "sample" {
    const input =
        \\########
        \\#..O.O.#
        \\##@.O..#
        \\#...O..#
        \\#.#.O..#
        \\#...O..#
        \\#......#
        \\########
        \\
        \\<^^>>>vv<v>>v<<
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(2028, sol.p1);
}

test "larger example" {
    const input =
        \\##########
        \\#..O..O.O#
        \\#......O.#
        \\#.OO..O.O#
        \\#..O@..O.#
        \\#O#..O...#
        \\#O..O..O.#
        \\#.OO.O.OO#
        \\#....O...#
        \\##########
        \\
        \\<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
        \\vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
        \\><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
        \\<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
        \\^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
        \\^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
        \\>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
        \\<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
        \\^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
        \\v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(10092, sol.p1);
    try std.testing.expectEqual(9021, sol.p2);
}
