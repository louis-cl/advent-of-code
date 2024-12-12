const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u32 };

const Index = struct {
    n: usize,

    pub fn of(self: *const Index, i: i32, j: i32) usize {
        return @as(usize, @intCast(i)) * self.n + @as(usize, @intCast(j));
    }

    pub fn of2(self: *const Index, i: usize, j: usize) usize {
        return i * self.n + j;
    }

    pub fn contains(self: *const Index, i: i32, j: i32) bool {
        return i >= 0 and j >= 0 and i < self.n and j < self.n;
    }
};

const vec2 = @Vector(2, i32);
const ORTHO = [4]vec2{ vec2{ 1, 0 }, vec2{ 0, 1 }, vec2{ -1, 0 }, vec2{ 0, -1 } };

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
            map[idx.of(i, @intCast(j))] = c;
        }
        i += 1;
    }
    return Solution{ .p1 = try part1(this.allocator, map, idx), .p2 = try part2(this.allocator, map, idx) };
}

fn part1(allocator: mem.Allocator, map: []const u8, idx: Index) !u32 {
    const visited = try allocator.alloc(bool, map.len);
    defer allocator.free(visited);
    @memset(visited, false);
    // explore map
    var price: i32 = 0;
    for (0..idx.n) |i| {
        for (0..idx.n) |j| {
            const region = map[idx.of2(i, j)];
            const areaPerim = explore(map, visited, idx, region, vec2{ @intCast(i), @intCast(j) });
            price += areaPerim[0] * areaPerim[1];
        }
    }
    return @intCast(price);
}

fn explore(map: []const u8, visited: []bool, idx: Index, region: u8, pos: vec2) vec2 {
    if (!idx.contains(pos[0], pos[1])) return .{ 0, 1 }; // walked out -> 1 fence
    const z = idx.of(pos[0], pos[1]);
    if (map[z] != region) return .{ 0, 1 }; // walked out to != region -> 1 fence
    if (visited[z]) return .{ 0, 0 }; // skip
    visited[z] = true;
    var res = vec2{ 1, 0 }; // +1 area since not visited
    for (ORTHO) |dir| {
        const npos = pos + dir;
        res += explore(map, visited, idx, region, npos);
    }
    return res;
}

fn part2(allocator: mem.Allocator, map: []const u8, idx: Index) !u32 {
    const visited = try allocator.alloc(bool, map.len);
    defer allocator.free(visited);
    @memset(visited, false);
    // explore map
    var price: i32 = 0;
    for (0..idx.n) |i| {
        for (0..idx.n) |j| {
            const region = map[idx.of2(i, j)];
            const areaSides = explore2(map, visited, idx, region, vec2{ @intCast(i), @intCast(j) });
            price += areaSides[0] * areaSides[1];
        }
    }
    return @intCast(price);
}

fn explore2(map: []const u8, visited: []bool, idx: Index, region: u8, pos: vec2) vec2 {
    const z = idx.of(pos[0], pos[1]);
    if (visited[z]) return vec2{ 0, 0 }; // skip visited
    visited[z] = true;
    var res = vec2{ 1, 0 }; // +1 area since not visited

    // there is 1 side per corner
    //  the bottom left A  going to the right can be:
    //  convex corner       concave corner
    //  C?                  AA
    //  AB                  AB
    // where B, C, ? could be outside the map, still counts as a side
    for (ORTHO) |dir| {
        const npos = pos + dir;
        if (!isFence(map, idx, region, npos)) {
            res += explore2(map, visited, idx, region, npos);
        } else {
            const parallel = pos + if (dir[0] == 0) vec2{ -1, 0 } else vec2{ 0, -1 };
            if (isFence(map, idx, region, parallel) or !isFence(map, idx, region, parallel + dir)) {
                res[1] += 1;
            }
        }
    }
    return res;
}

fn isFence(map: []const u8, idx: Index, region: u8, pos: vec2) bool {
    return !idx.contains(pos[0], pos[1]) or map[idx.of(pos[0], pos[1])] != region;
}

fn print(map: []const u32, idx: Index) void {
    std.debug.print("\nDEBUG MAP\n", .{});
    for (0..idx.n) |i| {
        for (0..idx.n) |j| {
            std.debug.print("{d}", .{map[idx.of(@intCast(i), @intCast(j))]});
        }
        std.debug.print("\n", .{});
    }
}

test "sample1" {
    const input =
        \\AAAA
        \\BBCD
        \\BBCC
        \\EEEC
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(140, sol.p1);
    try std.testing.expectEqual(80, sol.p2);
}

test "sample2" {
    const input =
        \\OOOOO
        \\OXOXO
        \\OOOOO
        \\OXOXO
        \\OOOOO
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(772, sol.p1);
    try std.testing.expectEqual(436, sol.p2);
}

test "sample3" {
    const input =
        \\RRRRIICCFF
        \\RRRRIICCCF
        \\VVRRRCCFFF
        \\VVRCCCJFFF
        \\VVVVCJJCFE
        \\VVIVCCJJEE
        \\VVIIICJJEE
        \\MIIIIIJJEE
        \\MIIISIJEEE
        \\MMMISSJEEE
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(1930, sol.p1);
    try std.testing.expectEqual(1206, sol.p2);
}

test "sample4" {
    const input =
        \\EEEEE
        \\EXXXX
        \\EEEEE
        \\EXXXX
        \\EEEEE
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(236, sol.p2);
}

test "sample5" {
    const input =
        \\AAAAAA
        \\AAABBA
        \\AAABBA
        \\ABBAAA
        \\ABBAAA
        \\AAAAAA
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(368, sol.p2);
}
