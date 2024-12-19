const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u64, p2: u64 };

const Towels = std.ArrayList([]const u8);
pub fn solve(this: *const @This()) !Solution {
    // parse towels
    var towels = Towels.init(this.allocator);
    defer towels.deinit();

    var lines = mem.splitScalar(u8, this.input, '\n');
    var towel_line = mem.splitSequence(u8, lines.next().?, ", ");
    while (towel_line.next()) |towel| try towels.append(towel);

    var p1: u64 = 0;
    var p2: u64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const count = try possible(this.allocator, &towels, line);
        if (count > 0) p1 += 1;
        p2 += count;
    }

    return Solution{ .p1 = p1, .p2 = p2 };
}

fn possible(allocator: mem.Allocator, towels: *Towels, design: []const u8) !u64 {
    const partial = try allocator.alloc(?u64, design.len);
    defer allocator.free(partial);
    @memset(partial, null);
    // partial[i] = n iff design[i..] is possible in n ways
    return compute(partial, towels, design);
}

fn compute(partial: []?u64, towels: *Towels, design: []const u8) u64 {
    if (design.len == 0) return 1;
    if (partial[0]) |r| return r;
    var total: u64 = 0;
    for (towels.items) |towel| {
        if (!std.mem.startsWith(u8, design, towel)) continue;
        const rest = compute(partial[towel.len..], towels, design[towel.len..]);
        total += rest;
    }
    partial[0] = total;
    return total;
}

test "sample" {
    const input =
        \\r, wr, b, g, bwu, rb, gb, br
        \\
        \\brwrr
        \\bggr
        \\gbbr
        \\rrbgbr
        \\ubwu
        \\bwurrg
        \\brgr
        \\bbrgwb
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(6, sol.p1);
    try std.testing.expectEqual(16, sol.p2);
}
