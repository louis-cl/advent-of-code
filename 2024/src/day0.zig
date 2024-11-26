// This is year 2023 day 1
const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

pub fn part1(this: *const @This()) !?i64 {
    var line_it = mem.splitScalar(u8, this.input, '\n');
    var total: i64 = 0;
    while (line_it.next()) |line| {
        if (line.len == 0) continue; // last line
        // std.debug.print("got line '{s}'\n", .{line});
        total += first(line) * 10 + last(line);
    }
    return total;
}

fn first(line: []const u8) u8 {
    for (line) |char| {
        if (digit(char)) |c| {
            return c;
        }
    }
    unreachable;
}

fn last(line: []const u8) u8 {
    var it = mem.reverseIterator(line);
    while (it.next()) |char| {
        if (digit(char)) |c| {
            return c;
        }
    }
    unreachable;
}

fn digit(char: u8) ?u8 {
    if (std.ascii.isDigit(char)) {
        return char - '0';
    }
    return null;
}

const DIGITS = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

pub fn part2(this: *const @This()) !?i64 {
    var line_it = mem.splitScalar(u8, this.input, '\n');
    var total: i64 = 0;
    while (line_it.next()) |line| {
        if (line.len == 0) continue; // last line
        const first2 = blk: {
            for (0..line.len) |i| {
                if (digit(line[i])) |d| {
                    break :blk d;
                }
                for (0.., DIGITS) |d, digit_d| {
                    if (mem.startsWith(u8, line[i..], digit_d)) {
                        break :blk @as(u8, @intCast(d)) + 1;
                    }
                }
            }
            unreachable;
        };
        const second2 = blk: {
            for (0..line.len) |j| {
                const i = line.len - 1 - j;
                if (digit(line[i])) |d| {
                    break :blk d;
                }
                for (0.., DIGITS) |d, digit_d| {
                    if (i < digit_d.len - 1) continue;
                    const k = i + 1 - digit_d.len;
                    if (mem.startsWith(u8, line[k..], digit_d)) {
                        break :blk @as(u8, @intCast(d)) + 1;
                    }
                }
            }
            unreachable;
        };
        // std.debug.print("got line '{s}'\n", .{line});
        total += first2 * 10 + second2;
    }
    return total;
}

test "parses one line" {
    const problem: @This() = .{
        .input = "1abc2\n",
        .allocator = std.testing.allocator,
    };

    try std.testing.expectEqual(12, try problem.part1());
}

test "parses one line of part 2" {
    const problem: @This() = .{
        .input = "two1nine\n",
        .allocator = std.testing.allocator,
    };

    try std.testing.expectEqual(29, try problem.part2());
}
