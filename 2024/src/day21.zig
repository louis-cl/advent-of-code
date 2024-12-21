const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u64, p2: u64 };

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');
    var p1: u64 = 0;
    var p2: u64 = 0;
    while (iter.next()) |line| {
        if (line.len == 0) break;
        const len = digits(line, 2);
        const numeric = numericPart(line);
        std.debug.print("for {s} len {d} and num {d}\n", .{ line, len, numeric });
        p1 += len * numeric;
        p2 += digits(line, 25) * numeric;
    }
    return Solution{ .p1 = p1, .p2 = p2 };
}

fn numericPart(line: []const u8) u64 {
    return std.fmt.parseUnsigned(u64, line[0 .. line.len - 1], 10) catch unreachable;
}

const vec2 = @Vector(2, i16);

// x+ y+ = right, up
fn coordDigit(dig: u8) vec2 {
    return switch (dig) {
        '0' => vec2{ 1, 0 },
        'A' => vec2{ 2, 0 },
        else => {
            const n = dig - '0' - 1;
            return vec2{ n % 3, 1 + n / 3 };
        },
    };
}

test "coord digits" {
    try std.testing.expectEqual(vec2{ 2, 3 }, coordDigit('9'));
}

const Robots = struct {
    count: usize,
    data: [900]u64 = [_]u64{0} ** 900, // 25*6*6

    fn get(self: *@This(), depth: usize, from: vec2, to: vec2) *u64 {
        const i: usize = @intCast(2 * from[0] + from[1]);
        const j: usize = @intCast(2 * to[0] + to[1]);
        return &self.data[depth * 36 + i * 6 + j];
    }

    //    +---+---+
    //    | ^ | A |
    //+---+---+---+
    //| < | v | > |
    //+---+---+---+
    fn costCoord(self: *@This(), depth: usize, from: vec2, to: vec2) u64 {
        if (depth == self.count) {
            // std.debug.print(" is 1\n", .{});
            return 1;
        }
        const d = self.get(depth, from, to);
        if (d.* != 0) return d.*;
        const diff = to - from;
        var count: u64 = 0;
        // std.debug.print(" is diff {any}\n", .{diff});
        if (diff[0] == 0 and diff[1] == 0) {
            count += 1; // cost of A from A is 1
        } else if (diff[0] == 0) { // pure vertical
            const target: u8 = if (diff[1] > 0) '^' else 'v';
            count += self.forward(depth + 1, target) + extra(diff);
        } else if (diff[1] == 0) { // pure horizontal
            const target: u8 = if (diff[0] > 0) '>' else '<';
            count += self.forward(depth + 1, target) + extra(diff);
        } else if (diff[1] > 0) { // moving up
            if (diff[0] < 0) { // up-left
                count += self.diagonal(depth + 1, '<', '^') + extra(diff); // there should no extra
            } else { // up-right
                if (from[0] == 0 and to[1] == 1) { // gap
                    count += self.diagonal(depth + 1, '>', '^') + extra(diff);
                } else {
                    count += self.diagonal(depth + 1, '^', '>') + extra(diff);
                }
            }
        } else {
            if (diff[0] < 0) { // down-left
                if (from[1] == 1 and to[0] == 0) { // gap
                    count += self.diagonal(depth + 1, 'v', '<') + extra(diff);
                } else {
                    count += self.diagonal(depth + 1, '<', 'v') + extra(diff);
                }
            } else { // down-right
                count += self.diagonal(depth + 1, 'v', '>') + extra(diff); // there should be no extra
            }
        }
        d.* = count;
        // std.debug.print("{any}->{any}: {any} had cost {d}\n", .{ from, to, diff, count });
        return count;
    }
    fn cost(self: *@This(), depth: usize, from: u8, to: u8) u64 {
        // std.debug.print("{c} -> {c}", .{ from, to });
        return self.costCoord(depth, coord(from), coord(to));
    }
    fn coord(target: u8) vec2 {
        return switch (target) {
            '<' => vec2{ 0, 0 },
            'v' => vec2{ 1, 0 },
            '>' => vec2{ 2, 0 },
            '^' => vec2{ 1, 1 },
            'A' => vec2{ 2, 1 },
            else => unreachable,
        };
    }
    fn diagonal(self: *@This(), depth: usize, first: u8, second: u8) u64 {
        return self.cost(depth, 'A', first) //
        + self.cost(depth, first, second) //
        + self.cost(depth, second, 'A');
    }
    fn forward(self: *@This(), depth: usize, first: u8) u64 {
        return self.cost(depth, 'A', first) //
        + self.cost(depth, first, 'A');
    }
};

//+---+---+---+
//| 7 | 8 | 9 |
//+---+---+---+
//| 4 | 5 | 6 |
//+---+---+---+
//| 1 | 2 | 3 |
//+---+---+---+
//    | 0 | A |
//    +---+---+
fn digits(seq: []const u8, depth: usize) u64 {
    var dp = Robots{ .count = depth };
    var count: u64 = 0;
    var current = coordDigit('A');
    for (seq) |digit| {
        const next = coordDigit(digit);
        const diff = next - current;
        // std.debug.print("DIGIT {c}: {any}->{any}\n", .{ digit, current, next });
        // find sequence of <^v> then A that is needed
        if (diff[0] == 0 and diff[1] == 0) {
            count += 1; // cost of A from A is 1
        } else if (diff[0] == 0) { // pure vertical
            const target: u8 = if (diff[1] > 0) '^' else 'v';
            count += dp.forward(0, target) + extra(diff);
        } else if (diff[1] == 0) { // pure horizontal
            const target: u8 = if (diff[0] > 0) '>' else '<';
            count += dp.forward(0, target) + extra(diff);
        } else if (diff[1] > 0) { // moving up
            if (diff[0] < 0) { // up-left
                if (current[1] == 0 and next[0] == 0) { // going over the gap
                    count += dp.diagonal(0, '^', '<') + extra(diff);
                } else {
                    count += dp.diagonal(0, '<', '^') + extra(diff);
                }
            } else { // up-right
                count += dp.diagonal(0, '^', '>') + extra(diff);
            }
        } else {
            if (diff[0] < 0) { // down-left
                count += dp.diagonal(0, 'v', '<') + extra(diff);
            } else { // down-right
                if (current[0] == 0 and next[1] == 0) { // going over the gap
                    count += dp.diagonal(0, '>', 'v') + extra(diff);
                } else {
                    count += dp.diagonal(0, 'v', '>') + extra(diff);
                }
            }
        }
        current = next;
    }
    return count;
}

fn extra(diff: vec2) u64 {
    var tot: u64 = 0;
    if (@abs(diff[0]) > 1) tot += @abs(diff[0]) - 1;
    if (@abs(diff[1]) > 1) tot += @abs(diff[1]) - 1;
    return tot;
}

test "one digit" {
    try std.testing.expectEqual(4, digits("9", 0));
}

test "one level" {
    try std.testing.expectEqual(12, digits("980A", 0));
}

test "one digit d1" {
    // try std.testing.expectEqual(6, digits("9", 1));
    try std.testing.expectEqual(8, digits("0", 1));
}

test "full depth d2" {
    try std.testing.expectEqual(26, digits("980A", 1));
}

test "one digit d2" {
    try std.testing.expectEqual(14, digits("9", 2));
}

test "full d2" {
    try std.testing.expectEqual(60, digits("980A", 2));
}

test "sample individual" {
    try std.testing.expectEqual(68, digits("029A", 2));
    try std.testing.expectEqual(60, digits("980A", 2));
    try std.testing.expectEqual(68, digits("179A", 2));
    try std.testing.expectEqual(64, digits("456A", 2));
    try std.testing.expectEqual(64, digits("379A", 2));
}

test "sample" {
    const input =
        \\029A
        \\980A
        \\179A
        \\456A
        \\379A
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(126384, sol.p1);
}
