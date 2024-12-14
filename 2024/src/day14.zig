const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u32 };
const vec2 = @Vector(2, i32);

pub fn solve(this: *const @This()) !Solution {
    return solve2(this, 101, 103);
}

fn solve2(this: *const @This(), width: i32, height: i32) Solution {
    var robots = std.ArrayList([2]vec2).init(this.allocator);
    defer robots.deinit();
    var iter = mem.splitScalar(u8, this.input, '\n');
    var quadrants: [4]u32 = .{ 0, 0, 0, 0 };
    while (iter.next()) |line| {
        if (line.len == 0) break;
        const robot = parseLine(line);
        // std.debug.print("{any}\n", .{robot});
        const end = move(robot, 100, width, height);
        if (quadrant(end, width, height)) |q| quadrants[q] += 1;
        robots.append(.{ end, robot[1] }) catch unreachable; // let's assume the tree is after 100 steps
    }
    // std.debug.print("{any}\n", .{quadrants});
    return Solution{ .p1 = quadrants[0] * quadrants[1] * quadrants[2] * quadrants[3], .p2 = 100 + part2(robots.items, width, height) };
}

fn move(robot: [2]vec2, steps: i32, width: i32, height: i32) vec2 {
    const end = robot[0] + robot[1] * vec2{ steps, steps };
    return vec2{ @mod(end[0], width), @mod(end[1], height) };
}

fn quadrant(robot: vec2, width: i32, height: i32) ?usize {
    const midw = @divExact(width - 1, 2);
    const midh = @divExact(height - 1, 2);
    if (robot[0] == midw or robot[1] == midh) return null;
    var ret: usize = if (robot[0] <= midw) 0 else 1;
    ret += if (robot[1] <= midh) 0 else 2;
    return ret;
}

fn part2(robots: [][2]vec2, width: i32, height: i32) u32 {
    _ = width + height;
    // idea: if an image is formed robots must be close to each other
    // make 10x10 buckets and metrics is sum of count per bucket ^ 2, find a threshold manually and print
    var buckets = [_]u32{0} ** 121; // 11 x 11;
    var metric: u64 = 0;
    var count: u32 = 0;
    while (metric < 7200) : (count += 1) { // do one iteration
        for (robots, 0..) |rob, i| {
            const next_pos = move(rob, 1, width, height);
            robots[i][0] = next_pos;
            buckets[@intCast(@divTrunc(next_pos[0], 10) * 10 + @divTrunc(next_pos[1], 10))] += 1;
        }
        metric = 0;
        for (buckets, 0..) |b, i| {
            metric += b * b;
            buckets[i] = 0; // reset
        }
    }
    std.debug.print("THE MAP {d}\n", .{count});
    print(robots, @intCast(width), @intCast(height));
    return count;
}

fn print(robots: [][2]vec2, width: usize, height: usize) void {
    for (0..width) |x| {
        for (0..height) |y| {
            var char: u8 = '.';
            for (robots) |rob| {
                if (std.meta.eql(rob[0], vec2{ @intCast(x), @intCast(y) })) {
                    char = '#';
                    break;
                }
            }
            std.debug.print("{c}", .{char});
        }
        std.debug.print("\n", .{});
    }
}

fn parseLine(line: []const u8) [2]vec2 {
    var iter = mem.splitAny(u8, line, "=, ");
    _ = iter.next().?; // "p="
    const x = std.fmt.parseUnsigned(i32, iter.next().?, 10) catch unreachable;
    const y = std.fmt.parseUnsigned(i32, iter.next().?, 10) catch unreachable;
    _ = iter.next().?; // " v="
    const vx = std.fmt.parseInt(i32, iter.next().?, 10) catch unreachable;
    const vy = std.fmt.parseInt(i32, iter.next().?, 10) catch unreachable;
    return .{ vec2{ x, y }, vec2{ vx, vy } };
}

test "sample" {
    const input =
        \\p=0,4 v=3,-3
        \\p=6,3 v=-1,-3
        \\p=10,3 v=-1,2
        \\p=2,0 v=2,-1
        \\p=0,0 v=1,3
        \\p=3,0 v=-2,-2
        \\p=7,6 v=-1,-3
        \\p=3,0 v=-1,-2
        \\p=9,3 v=2,3
        \\p=7,3 v=-1,2
        \\p=2,4 v=2,-3
        \\p=9,5 v=-3,-3
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = problem.solve2(11, 7);
    try std.testing.expectEqual(12, sol.p1);
}
