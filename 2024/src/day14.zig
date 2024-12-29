const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u32 };
const vec2 = @Vector(2, u32);

const RobotMap = struct {
    robots: std.ArrayList([2]vec2),
    width: u32,
    height: u32,
    fn init(allocator: mem.Allocator, w: u32, h: u32) @This() {
        return @This(){
            .robots = std.ArrayList([2]vec2).init(allocator),
            .width = w,
            .height = h,
        };
    }

    fn read(this: *@This(), input: []const u8) void {
        var iter = mem.splitScalar(u8, input, '\n');
        while (iter.next()) |line| {
            if (line.len == 0) break;
            const robot = this.parseLine(line);
            // std.debug.print("{any}\n", .{robot});
            this.robots.append(robot) catch unreachable; // let's assume the tree is after 100 steps
        }
    }

    fn parseLine(this: *const @This(), line: []const u8) [2]vec2 {
        var iter = mem.splitAny(u8, line, "=, ");
        _ = iter.next().?; // "p="
        const x = std.fmt.parseUnsigned(u16, iter.next().?, 10) catch unreachable;
        const y = std.fmt.parseUnsigned(u16, iter.next().?, 10) catch unreachable;
        _ = iter.next().?; // " v="
        const vx = std.fmt.parseInt(i32, iter.next().?, 10) catch unreachable;
        const vy = std.fmt.parseInt(i32, iter.next().?, 10) catch unreachable;
        const w: i32 = @intCast(this.width);
        const h: i32 = @intCast(this.height);
        return .{ vec2{ x, y }, vec2{ @intCast(@mod(vx, w)), @intCast(@mod(vy, h)) } };
    }

    fn part1(this: *const @This()) u32 {
        var quadrants: [4]u32 = .{ 0, 0, 0, 0 };
        for (this.robots.items) |robot| {
            const end = this.move(robot, 100);
            if (this.quadrant(end)) |q| quadrants[q] += 1;
        }
        return quadrants[0] * quadrants[1] * quadrants[2] * quadrants[3];
    }

    fn quadrant(this: *const @This(), robot: vec2) ?usize {
        const midw = (this.width - 1) / 2;
        const midh = (this.height - 1) / 2;
        if (robot[0] == midw or robot[1] == midh) return null;
        var ret: usize = if (robot[0] <= midw) 0 else 1;
        ret += if (robot[1] <= midh) 0 else 2;
        return ret;
    }

    fn part2(this: *const @This()) u32 {
        // idea: if an image is formed robots must be close to each other
        // make 10x10 buckets and metrics is sum of count per bucket ^ 2, find a threshold manually and print
        var buckets = [_]u32{0} ** 121; // 11 x 11;
        var metric: u64 = 0;
        var count: u32 = 0;
        while (metric < 7200) : (count += 1) { // do one iteration
            for (this.robots.items, 0..) |rob, i| {
                const next_pos = this.move(rob, 1);
                this.robots.items[i][0] = next_pos;
                buckets[@intCast(@divTrunc(next_pos[0], 10) * 10 + @divTrunc(next_pos[1], 10))] += 1;
            }
            metric = 0;
            for (buckets, 0..) |b, i| {
                metric += b * b;
                buckets[i] = 0; // reset
            }
        }
        this.print();
        return count;
    }

    fn move(this: *const @This(), robot: [2]vec2, steps: u32) vec2 {
        const end = robot[0] + robot[1] * vec2{ steps, steps };
        return vec2{ end[0] % this.width, end[1] % this.height };
    }

    fn print(this: *const @This()) void {
        for (0..this.height) |y| {
            for (0..this.width) |x| {
                var char: u8 = '.';
                for (this.robots.items) |rob| {
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
};

pub fn solve(this: *const @This()) !Solution {
    var robotMap = RobotMap.init(this.allocator, 101, 103);
    defer robotMap.robots.deinit();
    robotMap.read(this.input);
    return Solution{ .p1 = robotMap.part1(), .p2 = robotMap.part2() };
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

    var robotMap = RobotMap.init(std.testing.allocator, 11, 7);
    defer robotMap.robots.deinit();
    robotMap.read(input);
    try std.testing.expectEqual(12, robotMap.part1());
}
