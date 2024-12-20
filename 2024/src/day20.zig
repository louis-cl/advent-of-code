const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u32 };

const vec2 = @Vector(2, i16);
const ORTHO = [4]vec2{ vec2{ 1, 0 }, vec2{ 0, 1 }, vec2{ -1, 0 }, vec2{ 0, -1 } };

const Grid = struct {
    map: []i32,
    width: usize,
    fn at(self: *@This(), i: usize, j: usize) *i32 {
        return &self.map[i * self.width + j];
    }
    fn atP(self: *@This(), p: vec2) *i32 {
        return self.at(@intCast(p[0]), @intCast(p[1]));
    }
    fn contains(self: *const @This(), p: vec2) bool {
        return p[0] >= 0 and p[1] >= 0 and p[0] < self.width and p[1] < self.width;
    }

    fn print(self: *@This()) void {
        for (0..self.width) |i| {
            for (0..self.width) |j| {
                const c: u8 = switch (self.at(i, j).*) {
                    -1 => '#',
                    0 => '.',
                    else => |d| '0' + @as(u8, @intCast(@rem(d, 10))),
                };
                std.debug.print("{c}", .{c});
            }
            std.debug.print("\n", .{});
        }
    }
};

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');
    const n = iter.peek().?.len;

    // idea: I should try to use input directly instead of remapping
    var grid = Grid{
        .map = try this.allocator.alloc(i32, n * n), //
        .width = n,
    };
    defer this.allocator.free(grid.map);

    var i: usize = 0;
    var start: vec2 = undefined;
    var end: vec2 = undefined;
    while (iter.next()) |line| {
        if (line.len == 0) break;
        for (line, 0..) |c, j| {
            const g = grid.at(i, j);
            g.* = 0;
            switch (c) {
                '.' => {},
                '#' => g.* = -1,
                'S' => start = .{ @intCast(i), @intCast(j) },
                'E' => end = .{ @intCast(i), @intCast(j) },
                else => unreachable,
            }
        }
        i += 1;
    }
    // std.debug.print("{any} to {any}\n", .{ start, end });
    breadcrumbs(&grid, start, end, 1);
    // grid.print();
    // std.debug.print("{d} and {d}", .{ grid.atP(start).*, grid.atP(end).* });

    return Solution{
        .p1 = part1(&grid, start, end), //
        .p2 = part2(&grid, start, end),
    };
}

fn part2(grid: *Grid, from: vec2, end: vec2) u32 {
    if (std.meta.eql(from, end)) return 0;
    const time = grid.atP(from).*;
    var count = shortcuts2(grid, from, time);
    for (ORTHO) |dir| {
        const next = from + dir;
        if (!grid.contains(next) or grid.atP(next).* != time + 1) continue; // out or not the next path
        count += part2(grid, next, end);
    }
    return count;
}

fn shortcuts2(grid: *Grid, from: vec2, time: i32) u32 {
    var count: u32 = 0;
    const radius: i16 = 20;
    var i = @max(0, from[0] - radius);
    const maxi = @min(@as(i16, @intCast(grid.width)) - 1, from[0] + radius);
    while (i <= maxi) : (i += 1) {
        const distI = @as(i16, @intCast(@abs(i - from[0])));
        var j = @max(0, from[1] + distI - radius);
        const maxj = @min(@as(i16, @intCast(grid.width)) - 1, from[1] + radius - distI);
        while (j <= maxj) : (j += 1) {
            const next = vec2{ i, j };
            std.debug.assert(grid.contains(next));
            const next_time = grid.atP(next).*;
            if (next_time == -1) continue; // wall
            const new_time = time + distI + @abs(j - from[1]);
            if (new_time < next_time) { // shortcut!
                const savings = next_time - new_time;
                if (savings >= 100) {
                    // std.debug.print("found shortcut {d} at {any}\n", .{ savings, next });
                    count += 1;
                }
            }
        }
    }
    return count;
}

fn part1(grid: *Grid, from: vec2, end: vec2) u32 {
    if (std.meta.eql(from, end)) return 0;
    const time = grid.atP(from).*;
    var count = shortcuts(grid, from, time);
    for (ORTHO) |dir| {
        const next = from + dir;
        if (!grid.contains(next) or grid.atP(next).* != time + 1) continue; // out or not the next path
        count += part1(grid, next, end);
    }
    return count;
}

fn shortcuts(grid: *Grid, from: vec2, time: i32) u32 {
    var count: u32 = 0;
    for (ORTHO) |dir| {
        const next = from + dir * vec2{ 2, 2 }; // walk 2 steps
        if (!grid.contains(next)) continue; // out
        const next_time = grid.atP(next).*;
        if (next_time == -1) continue; // wall
        if (next_time > time + 2) { // shortcut!
            const savings = next_time - time - 2;
            if (savings >= 100) count += 1;
        }
    }
    return count;
}

fn breadcrumbs(grid: *Grid, from: vec2, end: vec2, steps: i32) void {
    grid.atP(from).* = steps;
    if (std.meta.eql(from, end)) return;
    for (ORTHO) |dir| {
        const next = from + dir;
        if (!grid.contains(next) or grid.atP(next).* != 0) continue; // out or visited (> 0) or # (-1)
        breadcrumbs(grid, next, end, steps + 1);
    }
}

test "sample" {
    const input =
        \\###############
        \\#...#...#.....#
        \\#.#.#.#.#.###.#
        \\#S#...#.#.#...#
        \\#######.#.#.###
        \\#######.#.#...#
        \\#######.#.###.#
        \\###..E#...#...#
        \\###.#######.###
        \\#...###...#...#
        \\#.#####.#.###.#
        \\#.#...#.#.#...#
        \\#.#.#.#.#.#.###
        \\#...#...#...###
        \\###############
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    _ = try problem.solve();
}
