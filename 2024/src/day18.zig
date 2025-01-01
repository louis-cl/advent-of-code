const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: []u8 };
const vec2 = @Vector(2, i8);

const Grid = struct {
    map: []u32,
    width: usize,
    dist: []u32,
    fn at(self: *@This(), i: usize, j: usize) *u32 {
        return &self.map[i * self.width + j];
    }
    fn atP(self: *@This(), p: vec2) *u32 {
        return self.at(@intCast(p[0]), @intCast(p[1]));
    }
    fn distAtP(self: *@This(), p: vec2) *u32 {
        const i: usize = @intCast(p[0]);
        const j: usize = @intCast(p[1]);
        return &self.dist[i * self.width + j];
    }
    fn contains(self: *const @This(), p: vec2) bool {
        return p[0] >= 0 and p[1] >= 0 and p[0] < self.width and p[1] < self.width;
    }
};

pub fn solve(this: *const @This()) !Solution {
    var grid = try parse(this.allocator, this.input, 71);
    defer this.allocator.free(grid.map);
    defer this.allocator.free(grid.dist);
    const p1 = try part1(this.allocator, &grid, 1024);
    const p2 = try part2(this.allocator, &grid);
    return Solution{ .p1 = p1, .p2 = try std.fmt.allocPrint(this.allocator, "{d},{d}", .{ p2[0], p2[1] }) };
}

fn parse(allocator: mem.Allocator, input: []const u8, grid_size: usize) !Grid {
    var grid = Grid{
        .map = try allocator.alloc(u32, grid_size * grid_size), //
        .dist = try allocator.alloc(u32, grid_size * grid_size), //
        .width = grid_size,
    };
    @memset(grid.map, std.math.maxInt(u32));

    var iter = mem.splitScalar(u8, input, '\n');
    var time: u32 = 1;
    while (iter.next()) |line| {
        if (line.len == 0) break;
        var line_iter = mem.splitScalar(u8, line, ',');
        const x = try std.fmt.parseUnsigned(usize, line_iter.next().?, 10);
        const y = try std.fmt.parseUnsigned(usize, line_iter.next().?, 10);
        // std.debug.print("got {d},{d}\n", .{ x, y });
        grid.at(y, x).* = time;
        time += 1;
    }
    return grid;
}

const ORTHO = [4]vec2{ vec2{ 1, 0 }, vec2{ 0, 1 }, vec2{ -1, 0 }, vec2{ 0, -1 } };

fn part1(allocator: mem.Allocator, grid: *Grid, until: usize) !u32 {
    @memset(grid.dist, 0);
    //bfs from top-left to bottom-right
    const end: vec2 = @splat(@intCast(grid.width - 1));
    var q: std.fifo.LinearFifo(vec2, .Dynamic) = std.fifo.LinearFifo(vec2, .Dynamic).init(allocator);
    defer q.deinit();

    q.writeItem(vec2{ 0, 0 }) catch unreachable;

    while (q.readItem()) |pos| {
        if (q.readableLength() > 100) return 0;
        const cost = grid.distAtP(pos).*;
        // std.debug.print("exploring {any} cost {any}\n", .{ pos, cost });
        for (ORTHO) |dir| {
            const next = pos + dir;
            if (std.meta.eql(next, end)) return cost + 1;
            if (grid.contains(next) and grid.atP(next).* > until and grid.distAtP(next).* == 0) {
                grid.distAtP(next).* = cost + 1;
                q.writeItem(next) catch unreachable;
            }
        }
    }
    unreachable;
}

fn biggerFirst(context: *Grid, a: vec2, b: vec2) std.math.Order {
    return std.math.order(context.atP(a).*, context.atP(b).*).invert();
}
const PQ = std.PriorityQueue(vec2, *Grid, biggerFirst);

fn part2(allocator: mem.Allocator, grid: *Grid) ![2]i8 {
    @memset(grid.dist, 0);
    const end: vec2 = @splat(@intCast(grid.width - 1));
    var q = PQ.init(allocator, grid);
    defer q.deinit();
    const start = vec2{ 0, 0 };
    try q.add(start);
    grid.distAtP(start).* = 1;
    var min_pos: vec2 = start;
    out: while (q.removeOrNull()) |pos| {
        const time = grid.atP(pos).*;
        if (time < grid.atP(min_pos).*) {
            min_pos = pos;
        }
        for (ORTHO) |dir| {
            const next = pos + dir;
            if (!grid.contains(next) or grid.distAtP(next).* != 0) continue;
            if (std.meta.eql(end, next)) break :out; // found one path
            try q.add(next);
            grid.distAtP(next).* = 1;
        }
    }
    return .{ min_pos[1], min_pos[0] };
}

test "sample" {
    const input =
        \\5,4
        \\4,2
        \\4,5
        \\3,0
        \\2,1
        \\6,3
        \\2,4
        \\1,5
        \\0,6
        \\3,3
        \\2,6
        \\5,1
        \\1,2
        \\5,5
        \\2,5
        \\6,5
        \\1,4
        \\0,4
        \\6,4
        \\1,1
        \\6,1
        \\1,0
        \\0,5
        \\1,6
        \\2,0
        \\
    ;

    var grid = try parse(std.testing.allocator, input, 7);
    defer std.testing.allocator.free(grid.map);
    defer std.testing.allocator.free(grid.dist);
    const p1 = try part1(std.testing.allocator, &grid, 12);
    try std.testing.expectEqual(22, p1);

    const p2 = try part2(std.testing.allocator, &grid);
    try std.testing.expectEqual(.{ 6, 1 }, p2);
}
