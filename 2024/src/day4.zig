const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u32 };

pub fn solve(this: *const @This()) !Solution {
    var lines = std.ArrayList([]const u8).init(this.allocator);
    defer lines.deinit();
    var iter = mem.splitScalar(u8, this.input, '\n');
    while (iter.next()) |line| if (line.len > 0) lines.append(line) catch unreachable;
    return Solution{ .p1 = part1(lines.items), .p2 = part2(lines.items) };
}

// input is a rectangle
fn part1(input: [][]const u8) u32 {
    const xmax = input.len;
    const ymax = input[0].len;
    var count: u32 = 0;
    for (0..xmax) |x| {
        for (0..ymax) |y| {
            count += forwardMatches(input, x, y, xmax, ymax);
        }
    }
    return count;
}

fn forwardMatches(input: [][]const u8, x: usize, y: usize, xmax: usize, ymax: usize) u32 {
    return forwardMatchesPattern(input, x, y, xmax, ymax, "XMAS") +
        forwardMatchesPattern(input, x, y, xmax, ymax, "SAMX");
}

fn forwardMatchesPattern(input: [][]const u8, x: usize, y: usize, xmax: usize, ymax: usize, pattern: *const [4]u8) u32 {
    if (input[x][y] != pattern[0]) return 0;
    var count: u32 = 0;
    // increase x
    if (x + 3 < xmax and equal(pattern, input[x + 1][y], input[x + 2][y], input[x + 3][y])) count += 1;
    // increase y
    if (y + 3 < ymax and equal(pattern, input[x][y + 1], input[x][y + 2], input[x][y + 3])) count += 1;
    // increase x and y
    if (x + 3 < xmax and y + 3 < ymax and equal(pattern, input[x + 1][y + 1], input[x + 2][y + 2], input[x + 3][y + 3])) count += 1;
    // increase x, decrease y
    if (x + 3 < xmax and y >= 3 and equal(pattern, input[x + 1][y - 1], input[x + 2][y - 2], input[x + 3][y - 3])) count += 1;
    return count;
}

fn equal(pattern: *const [4]u8, a: u8, b: u8, c: u8) bool {
    return a == pattern[1] and b == pattern[2] and c == pattern[3];
}

fn part2(input: [][]const u8) u32 {
    var count: u32 = 0;
    for (1..input.len - 1) |x| {
        for (1..input[0].len - 1) |y| {
            if (input[x][y] == 'A' and isMS(input[x - 1][y - 1], input[x + 1][y + 1]) and isMS(input[x - 1][y + 1], input[x + 1][y - 1]))
                count += 1;
        }
    }
    return count;
}

fn isMS(a: u8, b: u8) bool {
    return (a == 'M' and b == 'S') or (a == 'S' and b == 'M');
}

test "sample" {
    const input =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(18, sol.p1);
    try std.testing.expectEqual(9, sol.p2);
}
