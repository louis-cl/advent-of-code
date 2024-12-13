const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: i64, p2: i64 };
const vec2 = @Vector(2, i64);

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');
    var p1: i64 = 0;
    var p2: i64 = 0;
    while (iter.next()) |line| {
        // 4 lines per input
        const button_a = parseLine(line);
        const button_b = parseLine(iter.next().?);
        const prize = parseLine(iter.next().?);
        _ = iter.next().?; // new line
        // std.debug.print("{any},{any},{any}\n", .{ button_a, button_b, prize });
        const pp1 = presses(button_a, button_b, prize);
        if (pp1[0] < 100 and pp1[1] < 100) p1 += 3 * pp1[0] + pp1[1];
        const pp2 = presses(button_a, button_b, prize + vec2{ 10000000000000, 10000000000000 });
        p2 += 3 * pp2[0] + pp2[1];
    }
    return Solution{ .p1 = p1, .p2 = p2 };
}

fn parseLine(line: []const u8) vec2 {
    var iter = mem.splitAny(u8, line, "+,=");
    _ = iter.next().?; // "Button A: X+"
    const x = std.fmt.parseUnsigned(i64, iter.next().?, 10) catch unreachable;
    _ = iter.next().?; // ", Y+"
    const y = std.fmt.parseUnsigned(i64, iter.next().?, 10) catch unreachable;
    return vec2{ x, y };
}

fn presses(a: vec2, b: vec2, p: vec2) vec2 {
    var det = a[0] * b[1] - a[1] * b[0];
    if (det == 0) unreachable; // let's see if it happens
    var x = b[1] * p[0] - b[0] * p[1];
    var y = a[0] * p[1] - a[1] * p[0];
    if (det < 0) {
        x *= -1;
        y *= -1;
        det *= -1;
    }
    if (@rem(x, det) != 0 or @rem(y, det) != 0) return @splat(0); // non integer solution
    x = @divExact(x, det);
    y = @divExact(y, det);
    if (x < 0 or y < 0) return @splat(0);
    return vec2{ x, y };
}

test "sample" {
    const input =
        \\Button A: X+94, Y+34
        \\Button B: X+22, Y+67
        \\Prize: X=8400, Y=5400
        \\
        \\Button A: X+26, Y+66
        \\Button B: X+67, Y+21
        \\Prize: X=12748, Y=12176
        \\
        \\Button A: X+17, Y+86
        \\Button B: X+84, Y+37
        \\Prize: X=7870, Y=6450
        \\
        \\Button A: X+69, Y+23
        \\Button B: X+27, Y+71
        \\Prize: X=18641, Y=10279
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(480, sol.p1);
}
