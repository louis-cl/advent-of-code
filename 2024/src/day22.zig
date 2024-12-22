const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u64, p2: u64 };

const Part2 = struct {
    counter: []u32,
    seen: []bool,
    fn slot(nums: [4]u8) usize {
        var z: usize = 0;
        for (nums) |x| z = z * 19 + x;
        return z;
    }
    fn scan(this: *@This(), s: u24) void {
        @memset(this.seen, false);
        // initialize the first 4 numbers
        var nums: [4]u8 = undefined; // diffs + 9
        var last_digit: u8 = @intCast(s % 10);
        var last_secret = s;
        for (0..4) |i| {
            last_secret = next(last_secret);
            const new_digit: u8 = @intCast(last_secret % 10);
            nums[i] = 9 + new_digit - last_digit;
            last_digit = new_digit;
        }
        this.record(nums, last_digit);
        // loop the rest
        for (0..2000 - 4) |_| {
            mem.rotate(u8, &nums, 1);
            last_secret = next(last_secret);
            const new_digit: u8 = @intCast(last_secret % 10);
            nums[3] = 9 + new_digit - last_digit;
            last_digit = new_digit;
            this.record(nums, last_digit);
        }
    }
    fn record(this: *@This(), nums: [4]u8, bananas: u32) void {
        const z = slot(nums);
        if (!this.seen[z]) { // only the first time
            this.seen[z] = true;
            this.counter[z] += bananas;
        }
    }
    fn best(this: *const @This()) u32 {
        return mem.max(u32, this.counter);
    }
};

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');

    // digit is in [0,9], diff in [-9,9] eq [0,18] => 19 values
    var part2 = Part2{
        .counter = try this.allocator.alloc(u32, 19 * 19 * 19 * 19), // TODO: check if faster on stack
        .seen = try this.allocator.alloc(bool, 19 * 19 * 19 * 19),
    };
    @memset(part2.counter, 0);
    defer this.allocator.free(part2.counter);
    defer this.allocator.free(part2.seen);

    var p1: u64 = 0;
    while (iter.next()) |line| {
        if (line.len == 0) break;
        const secret = try std.fmt.parseUnsigned(u24, line, 10);
        p1 += skip(secret, 2000);
        part2.scan(secret);
    }
    return Solution{ .p1 = p1, .p2 = part2.best() };
}

fn skip(s: u24, count: usize) u24 {
    var res = s;
    for (0..count) |_| res = next(res);
    return res;
}

fn next(s: u24) u24 {
    var res = s;
    res ^= res << 6;
    res ^= res >> 5;
    res ^= res << 11;
    return res;
}

test "sample" {
    const input =
        \\1
        \\10
        \\100
        \\2024
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(37327623, sol.p1);
}

test "sample2" {
    const input =
        \\1
        \\2
        \\3
        \\2024
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(23, sol.p2); // at -2,1,-1,3
}
