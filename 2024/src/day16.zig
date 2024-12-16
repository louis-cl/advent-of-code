const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u32 };

const vec2 = @Vector(2, i16);
const Grid = struct {
    map: []bool,
    width: usize,
    dist: []u32,
    fn at(self: *@This(), i: usize, j: usize) *bool {
        return &self.map[i * self.width + j];
    }
    fn atP(self: *@This(), p: vec2) *bool {
        return self.at(@intCast(p[0]), @intCast(p[1]));
    }

    fn distAt(self: *@This(), p: vec2, dir: vec2) *u32 {
        const z = encodePos(p, self.width) * 4 + encodeDir(dir);
        return &self.dist[z];
    }

    fn distsAt(self: *const @This(), p: vec2) []u32 {
        const z = encodePos(p, self.width) * 4;
        return self.dist[z .. z + 4];
    }

    fn updateIfLower(self: *@This(), p: vec2, dir: vec2, val: u32) bool {
        const d = self.distAt(p, dir);
        if (val < d.*) {
            d.* = val;
            return true;
        }
        return false;
    }
};

fn encodeDir(dir: vec2) usize {
    // when you wish direction was an enum...
    const dx = dir[0];
    const dy = dir[1];
    if (dx == 0 and dy == 1) {
        return 0;
    } else if (dx == 1 and dy == 0) {
        return 1;
    } else if (dx == 0 and dy == -1) {
        return 2;
    } else if (dx == -1 and dy == 0) {
        return 3;
    } else {
        unreachable;
    }
}

fn encodePos(pos: vec2, width: usize) usize {
    const x: usize = @intCast(pos[0]);
    const y: usize = @intCast(pos[1]);
    return x * width + y;
}

fn encode(state: State, width: usize) usize {
    return encodePos(state.pos, width) * 4 + encodeDir(state.dir);
}

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');
    // parse map
    const n = iter.peek().?.len; // square map
    var grid = Grid{
        .map = try this.allocator.alloc(bool, n * n), //
        .dist = try this.allocator.alloc(u32, n * n * 4), // i, j, dir
        .width = n,
    };
    defer this.allocator.free(grid.map);
    defer this.allocator.free(grid.dist);
    @memset(grid.dist, std.math.maxInt(u32));

    var start: vec2 = undefined;
    var end: vec2 = undefined;
    var i: usize = 0;
    while (iter.next()) |line| {
        if (line.len == 0) break; // done
        std.debug.assert(line.len == n);
        for (line, 0..) |c, j| {
            grid.at(i, j).* = c == '#'; // true = blocked
            if (c == 'S') {
                start = vec2{ @intCast(i), @intCast(j) };
            } else if (c == 'E') {
                end = vec2{ @intCast(i), @intCast(j) };
            }
        }
        i += 1;
    }
    std.debug.assert(i == n);
    std.debug.assert(start[0] != 0);
    std.debug.assert(end[0] != 0);

    explore(this.allocator, &grid, start, end);
    const p1 = mem.min(u32, grid.distsAt(end));
    return Solution{ .p1 = p1, .p2 = part2(&grid, end, p1) };
}

const State = struct { cost: u32, pos: vec2, dir: vec2 };
fn stateOrder(context: void, a: State, b: State) std.math.Order {
    _ = context;
    return std.math.order(a.cost, b.cost);
}
const PQ = std.PriorityQueue(State, void, stateOrder);

fn explore(allocator: mem.Allocator, grid: *Grid, start: vec2, end: vec2) void {
    var q = PQ.init(allocator, {});
    // q.ensureTotalCapacity(grid.map.len); check if this helps performance
    defer q.deinit();

    const startState = State{ .cost = 0, .pos = start, .dir = vec2{ 0, 1 } };
    q.add(startState) catch unreachable;
    grid.distAt(startState.pos, startState.dir).* = 0;

    while (q.removeOrNull()) |p| {
        // std.debug.print("exploring {any}\n", .{p});
        if (std.meta.eql(p.pos, end)) break; // done, guaranteed min cost
        // forward
        const forward = State{ .cost = p.cost + 1, .pos = p.pos + p.dir, .dir = p.dir };
        if (!grid.atP(forward.pos).*) {
            if (grid.updateIfLower(forward.pos, forward.dir, forward.cost)) {
                q.add(forward) catch unreachable;
            }
        }
        // rotate
        const rot = vec2{ -p.dir[1], p.dir[0] }; // no idea if this is cw or ccw
        const rot1 = State{ .cost = p.cost + 1000, .pos = p.pos, .dir = rot };
        const rot2 = State{ .cost = p.cost + 1000, .pos = p.pos, .dir = -rot };
        if (grid.updateIfLower(rot1.pos, rot1.dir, rot1.cost)) {
            q.add(rot1) catch unreachable;
        }
        if (grid.updateIfLower(rot2.pos, rot2.dir, rot2.cost)) {
            q.add(rot2) catch unreachable;
        }
    }
}

const ORTHO = [4]vec2{ vec2{ 1, 0 }, vec2{ 0, 1 }, vec2{ -1, 0 }, vec2{ 0, -1 } };
fn part2(grid: *Grid, end: vec2, min_cost: u32) u32 {
    // idea is to walk back from the end in decreasing cost
    // if end has cost C, all the neighbours with cost C-"cost to step to end" are part of a min path
    // add walls in already visited positions
    // can use DFS to simplify algorithm
    var count: u32 = 1; // end
    grid.atP(end).* = true; // visited end
    for (ORTHO) |dir| {
        count += walkback(grid, end, dir, min_cost);
    }
    return count;
}

fn walkback(grid: *Grid, pos: vec2, dir: vec2, expected_cost: u32) u32 {
    if (expected_cost == 0) return 0;
    var count: u32 = 0;
    // backwards
    const origin = pos - dir;
    if (!grid.atP(origin).* and grid.distAt(origin, dir).* == expected_cost - 1) {
        grid.atP(origin).* = true;
        count += 1;
        if (expected_cost > 0) count += walkback(grid, origin, dir, expected_cost - 1);
    }
    // rotate
    if (expected_cost >= 1000) {
        const rot = vec2{ -dir[1], dir[0] };
        if (grid.distAt(pos, rot).* == expected_cost - 1000) {
            count += walkback(grid, pos, rot, expected_cost - 1000);
        }
        if (grid.distAt(pos, -rot).* == expected_cost - 1000) {
            count += walkback(grid, pos, -rot, expected_cost - 1000);
        }
    }
    return count;
}

test "sample" {
    const input =
        \\###############
        \\#.......#....E#
        \\#.#.###.#.###.#
        \\#.....#.#...#.#
        \\#.###.#####.#.#
        \\#.#.#.......#.#
        \\#.#.#####.###.#
        \\#...........#.#
        \\###.#.#####.#.#
        \\#...#.....#.#.#
        \\#.#.#.###.#.#.#
        \\#.....#...#.#.#
        \\#.###.#.#.#.#.#
        \\#S..#.....#...#
        \\###############
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(7036, sol.p1);
    try std.testing.expectEqual(45, sol.p2);
}

test "sample2" {
    const input =
        \\#################
        \\#...#...#...#..E#
        \\#.#.#.#.#.#.#.#.#
        \\#.#.#.#...#...#.#
        \\#.#.#.#.###.#.#.#
        \\#...#.#.#.....#.#
        \\#.#.#.#.#.#####.#
        \\#.#...#.#.#.....#
        \\#.#.#####.#.###.#
        \\#.#.#.......#...#
        \\#.#.###.#####.###
        \\#.#.#...#.....#.#
        \\#.#.#.#####.###.#
        \\#.#.#.........#.#
        \\#.#.#.#########.#
        \\#S#.............#
        \\#################
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(11048, sol.p1);
    try std.testing.expectEqual(64, sol.p2);
}
