const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: i32 };

const Index = struct {
    n: usize,

    pub fn of(self: *const Index, i: i32, j: i32) usize {
        return @as(usize, @intCast(i)) * self.n + @as(usize, @intCast(j));
    }

    pub fn contains(self: *const Index, i: i32, j: i32) bool {
        return i >= 0 and j >= 0 and i < self.n and j < self.n;
    }
};

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');
    const n = iter.peek().?.len; // assume input is a square
    const map = try this.allocator.alloc(u8, n * n);
    defer this.allocator.free(map);

    const idx = Index{ .n = n };
    var i: i32 = 0;
    while (iter.next()) |line| {
        if (line.len == 0) break;
        std.debug.assert(line.len == n); // really a square
        for (line, 0..) |c, j| {
            map[idx.of(@intCast(i), @intCast(j))] = c - '0';
        }
        i += 1;
    }
    return Solution{ .p1 = try part1(this.allocator, map, idx), .p2 = try part2(this.allocator, map, idx) };
}

fn part1(allocator: mem.Allocator, map: []const u8, idx: Index) !u32 {
    var sum: u32 = 0;
    const seen = try allocator.alloc(bool, map.len);
    defer allocator.free(seen);

    for (0..idx.n) |i| {
        for (0..idx.n) |j| {
            if (map[idx.of(@intCast(i), @intCast(j))] == 0) {
                @memset(seen, false);
                sum += score(map, seen, idx, @intCast(i), @intCast(j), 0);
            }
        }
    }
    return sum;
}

fn score(map: []const u8, seen: []bool, idx: Index, i: i32, j: i32, expected: u8) u32 {
    if (!idx.contains(i, j)) return 0;
    const z = idx.of(i, j);
    if (map[z] != expected) return 0;
    if (expected == 9) {
        if (seen[z]) return 0;
        seen[z] = true;
        return 1;
    }
    return score(map, seen, idx, i + 1, j, expected + 1) //
    + score(map, seen, idx, i, j + 1, expected + 1) //
    + score(map, seen, idx, i - 1, j, expected + 1) //
    + score(map, seen, idx, i, j - 1, expected + 1);
}

fn part2(allocator: mem.Allocator, map: []const u8, idx: Index) !i32 {
    var sum: i32 = 0;
    const seen = try allocator.alloc(i32, map.len);
    defer allocator.free(seen);
    @memset(seen, -1); // sentinel
    for (0..idx.n) |i| {
        for (0..idx.n) |j| {
            if (map[idx.of(@intCast(i), @intCast(j))] == 0) {
                sum += trails(map, seen, idx, @intCast(i), @intCast(j), 0);
            }
        }
    }
    return sum;
}

fn trails(map: []const u8, seen: []i32, idx: Index, i: i32, j: i32, expected: u8) i32 {
    if (!idx.contains(i, j)) return 0;
    const z = idx.of(i, j);
    if (map[z] != expected) return 0;
    if (seen[z] < 0) {
        if (expected == 9) {
            seen[z] = 1;
        } else {
            seen[z] = trails(map, seen, idx, i + 1, j, expected + 1) //
            + trails(map, seen, idx, i, j + 1, expected + 1) //
            + trails(map, seen, idx, i - 1, j, expected + 1) //
            + trails(map, seen, idx, i, j - 1, expected + 1);
        }
    }
    return seen[z];
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
