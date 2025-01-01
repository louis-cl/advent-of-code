const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u64, p2: u64 };

const Part2 = struct {
    counter: []u32,
    seen: []u16,
    scan_id: u16 = 0,
    fn slot(nums: [4]u8) usize {
        var z: usize = 0;
        for (nums) |x| z = z * 19 + x;
        return z;
    }
    fn scan(this: *@This(), s: u24) void {
        this.scan_id += 1;
        // initialize the first 4 numbers
        var nums: [4]u8 = undefined; // diffs + 9
        var last_digit: u8 = @intCast(s % 10);
        var last_secret = s;
        for (0..4) |i| {
            last_secret = next(last_secret);
            const new_digit: u8 = @as(u8, @truncate(last_secret)) % 10;
            nums[i] = 9 + new_digit - last_digit;
            last_digit = new_digit;
        }
        var last_z: usize = slot(nums);
        this.record(last_z, last_digit);
        // loop the rest
        for (0..2000 - 4) |_| {
            last_secret = next(last_secret);
            const new_digit: u8 = @as(u8, @truncate(last_secret)) % 10;
            const new_val = 9 + new_digit - last_digit;
            const t: usize = @intCast(nums[0]);
            last_z = (last_z - t * 19 * 19 * 19) * 19 + new_val;
            mem.rotate(u8, &nums, 1);
            nums[3] = new_val;
            last_digit = new_digit;
            this.record(last_z, last_digit);
        }
    }
    fn record(this: *@This(), z: usize, bananas: u32) void {
        if (this.seen[z] != this.scan_id) { // only the first time
            this.seen[z] = this.scan_id;
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
        .seen = try this.allocator.alloc(u16, 19 * 19 * 19 * 19),
    };
    @memset(part2.counter, 0);
    @memset(part2.seen, 0);
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
