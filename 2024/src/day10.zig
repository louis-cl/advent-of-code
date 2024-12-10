const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: i32 };

const Map = struct {
    map: []u8,
    n: usize,

    pub fn get(self: *const Map, i: i32, j: i32) u8 {
        return self.map[self.idx(i, j)];
    }

    pub fn set(self: *Map, i: i32, j: i32, val: u8) void {
        self.map[self.idx(i, j)] = val;
    }

    pub fn idx(self: *const Map, i: i32, j: i32) usize {
        return @as(usize, @intCast(i)) * self.n + @as(usize, @intCast(j));
    }

    pub fn contains(self: *const Map, i: i32, j: i32) bool {
        return i >= 0 and j >= 0 and i < self.n and j < self.n;
    }
};

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');
    const n = iter.peek().?.len; // assume input is a square
    var map = Map{
        .map = try this.allocator.alloc(u8, n * n),
        .n = n,
    };
    defer this.allocator.free(map.map);
    var i: i32 = 0;
    while (iter.next()) |line| {
        if (line.len == 0) break;
        std.debug.assert(line.len == n); // really a square
        for (line, 0..) |c, j| {
            map.set(i, @intCast(j), c - '0');
        }
        i += 1;
    }
    return Solution{ .p1 = try part1(this.allocator, map), .p2 = try part2(this.allocator, map) };
}

fn part1(allocator: mem.Allocator, map: Map) !u32 {
    var sum: u32 = 0;
    const seen = try allocator.alloc(bool, map.map.len);
    defer allocator.free(seen);

    for (0..map.n) |i| {
        for (0..map.n) |j| {
            if (map.get(@intCast(i), @intCast(j)) == 0) {
                @memset(seen, false);
                sum += score(map, seen, @intCast(i), @intCast(j), 0);
            }
        }
    }
    return sum;
}

fn score(map: Map, seen: []bool, i: i32, j: i32, expected: u8) u32 {
    if (!map.contains(i, j)) return 0;
    const current = map.get(i, j);
    if (current != expected) return 0;
    if (current == 9) {
        const s = &seen[map.idx(i, j)];
        if (s.*) return 0;
        s.* = true;
        return 1;
    }
    return score(map, seen, i + 1, j, current + 1) + score(map, seen, i, j + 1, current + 1) + score(map, seen, i - 1, j, current + 1) + score(map, seen, i, j - 1, current + 1);
}

fn part2(allocator: mem.Allocator, map: Map) !i32 {
    var sum: i32 = 0;
    const seen = try allocator.alloc(i32, map.map.len);
    defer allocator.free(seen);
    @memset(seen, -1);
    for (0..map.n) |i| {
        for (0..map.n) |j| {
            if (map.get(@intCast(i), @intCast(j)) == 0) {
                sum += trails(map, seen, @intCast(i), @intCast(j), 0);
            }
        }
    }
    return sum;
}

fn trails(map: Map, seen: []i32, i: i32, j: i32, expected: u8) i32 {
    if (!map.contains(i, j)) return 0;
    const current = map.get(i, j);
    if (current != expected) return 0;
    const s = &seen[map.idx(i, j)];
    if (s.* < 0) {
        if (current == 9) {
            s.* = 1;
        } else {
            s.* = trails(map, seen, i + 1, j, current + 1) + trails(map, seen, i, j + 1, current + 1) + trails(map, seen, i - 1, j, current + 1) + trails(map, seen, i, j - 1, current + 1);
        }
    }
    return s.*;
}

test "sample" {
    const input =
        \\89010123
        \\78121874
        \\87430965
        \\96549874
        \\45678903
        \\32019012
        \\01329801
        \\10456732
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(36, sol.p1);
    try std.testing.expectEqual(81, sol.p2);
}
