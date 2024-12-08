const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u32 };
const Point = struct { x: i32, y: i32 };

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');
    const N = 10 + 26 + 26;
    var antenas = try this.allocator.alloc(std.ArrayList(Point), N);
    for (0..N) |i| antenas[i] = std.ArrayList(Point).init(this.allocator);
    defer {
        for (0..N) |i| antenas[i].deinit();
        this.allocator.free(antenas);
    }
    // parse
    var x: i32 = 0;
    while (iter.next()) |line| {
        if (line.len == 0) break;
        var y: i32 = 0;
        for (line) |char| {
            switch (char) {
                '0'...'9' => try antenas[char - '0'].append(Point{ .x = x, .y = y }),
                'a'...'z' => try antenas[char - 'a' + 10].append(Point{ .x = x, .y = y }),
                'A'...'Z' => try antenas[char - 'A' + 10 + 26].append(Point{ .x = x, .y = y }),
                else => {},
            }
            y += 1;
        }
        x += 1;
    }
    // for (antenas) |ant| {
    //     std.debug.print("\t{any}\n", .{ant.items});
    // }
    return Solution{ .p1 = part1(this.allocator, antenas, x), .p2 = part2(this.allocator, antenas, x) };
}

fn part1(allocator: mem.Allocator, antenas: []std.ArrayList(Point), n: i32) u32 {
    var seen = std.AutoHashMap(Point, void).init(allocator);
    defer seen.deinit();
    for (antenas) |ants| {
        if (ants.items.len <= 1) continue;
        for (ants.items[1..], 1..) |a, i| {
            for (ants.items[0..i]) |b| {
                // diff = a - b
                // t = a + diff = 2*a - b
                // r = b - diff = 2*b - a
                const t = Point{ .x = 2 * a.x - b.x, .y = 2 * a.y - b.y };
                const r = Point{ .x = 2 * b.x - a.x, .y = 2 * b.y - a.y };
                if (isIn(t, n)) seen.put(t, {}) catch unreachable;
                if (isIn(r, n)) seen.put(r, {}) catch unreachable;
            }
        }
    }
    return seen.count();
}

fn isIn(point: Point, n: i32) bool {
    return point.x >= 0 and point.y >= 0 and point.x < n and point.y < n;
}

fn part2(allocator: mem.Allocator, antenas: []std.ArrayList(Point), n: i32) u32 {
    var seen = std.AutoHashMap(Point, void).init(allocator);
    defer seen.deinit();
    for (antenas) |ants| {
        if (ants.items.len <= 1) continue;
        for (ants.items[1..], 1..) |a, i| {
            for (ants.items[0..i]) |b| {
                var dx = a.x - b.x;
                var dy = a.y - b.y;
                // reduce the fraction 2 4 => 1 2
                if (dx != 0 and dy != 0) {
                    const gcd = @as(i32, @intCast(std.math.gcd(@abs(dx), @abs(dy))));
                    dx = @divExact(dx, gcd);
                    dy = @divExact(dy, gcd);
                }
                // print all positions from a in direction dx,dy
                // forward
                var t = a;
                while (isIn(t, n)) {
                    seen.put(t, {}) catch unreachable;
                    t = Point{ .x = t.x + dx, .y = t.y + dy };
                }
                // backward
                t = a; // okay to do a again
                while (isIn(t, n)) {
                    seen.put(t, {}) catch unreachable;
                    t = Point{ .x = t.x - dx, .y = t.y - dy };
                }
            }
        }
    }
    return seen.count();
}

test "sample" {
    const input =
        \\............
        \\........0...
        \\.....0......
        \\.......0....
        \\....0.......
        \\......A.....
        \\............
        \\............
        \\........A...
        \\.........A..
        \\............
        \\............
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(14, sol.p1);
    try std.testing.expectEqual(34, sol.p2);
}
