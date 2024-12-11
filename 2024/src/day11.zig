const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u64, p2: u64 };

const Stone = struct {
    num: u64,
    blinks: u64,

    fn step(self: *const Stone, new: u64) Stone {
        std.debug.assert(self.blinks > 0);
        return Stone{ .blinks = self.blinks - 1, .num = new };
    }
};

pub fn solve(this: *const @This()) !Solution {
    // stones (num, blinks) = # of stones of a stone engraved with `num` after `blinks` blinks
    var stones = std.AutoHashMap(Stone, u64).init(this.allocator);
    defer stones.deinit();

    var p1: u64 = 0;
    var p2: u64 = 0;
    var iter = mem.splitScalar(u8, this.input, ' ');
    while (iter.next()) |token| {
        const x = try std.fmt.parseUnsigned(u64, token, 10);
        p1 += try simulate(&stones, x, 25);
        p2 += try simulate(&stones, x, 75);
    }
    return Solution{ .p1 = p1, .p2 = p2 };
}

fn simulate(stones: *std.AutoHashMap(Stone, u64), num: u64, blinks: u64) !u64 {
    return try doStones(stones, Stone{ .num = num, .blinks = blinks });
}

fn doStones(stones: *std.AutoHashMap(Stone, u64), stone: Stone) !u64 {
    if (stone.blinks == 0) return 1;
    if (stone.num == 0) return doStones(stones, stone.step(1));
    // cached result
    if (stones.get(stone)) |c| {
        return c;
    }
    // even number of digits
    if (split(stone.num)) |parts| {
        const left = stone.step(parts[0]);
        const right = stone.step(parts[1]);
        const val = try doStones(stones, left) + try doStones(stones, right);
        try stones.put(stone, val);
        return val;
    }
    return doStones(stones, stone.step(stone.num * 2024));
}

fn split(x: u64) ?[2]u64 {
    var higher: u64 = 100;
    var lower: u64 = 10;
    var base: u64 = 10;
    while (lower <= x) {
        if (x < higher) return .{ x / base, x % base };
        lower *= 100;
        higher *= 100;
        base *= 10;
    }
    return null;
}

test "split" {
    try std.testing.expectEqual(.{ 10, 0 }, split(1000));
    try std.testing.expectEqual(.{ 102, 334 }, split(102334));
    try std.testing.expectEqual(null, split(1));
    try std.testing.expectEqual(null, split(134));
}

test "simulate" {
    var stones = std.AutoHashMap(Stone, u64).init(std.testing.allocator);
    defer stones.deinit();
    const res = try doStones(&stones, Stone{ .blinks = 6, .num = 125 }) //
    + try doStones(&stones, Stone{ .blinks = 6, .num = 17 });
    try std.testing.expectEqual(22, res);
}

test "sample" {
    const problem: @This() = .{
        .input = "125 17",
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(55312, sol.p1);
}
