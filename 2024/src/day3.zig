const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u32 };
const Mul = struct { left: u32, right: u32 };

pub fn solve(this: *const @This()) !Solution {
    var data = this.input;
    var p1: u32 = 0;
    while (data.len > 0) {
        const mul = parseMul(data);
        data = mul.rest;
        if (mul.mul) |m| {
            p1 += m.left * m.right;
        }
    }

    return Solution{ .p1 = p1, .p2 = 0 };
}

fn parseMul(input: []const u8) struct { rest: []const u8, mul: ?Mul } {
    var i: u8 = 0;
    // mul(
    while (i < input.len and !mem.startsWith(u8, input[i..], "mul(")) i += 1;
    if (i >= input.len) return .{ .rest = "", .mul = null };
    i += 4;
    // std.debug.print("GOT MUL, rest {s}\n", .{input[i..]});

    // number
    const left = parseNum(input[i..]);
    if (left.n == null) return .{ .rest = left.rest, .mul = null };
    // std.debug.print("GOT LEFT\n", .{});

    // ,
    if (left.rest.len < 1) return .{ .rest = "", .mul = null };
    if (left.rest[0] != ',') return .{ .rest = left.rest[1..], .mul = null };
    // std.debug.print("GOT ,\n", .{});

    // number
    const right = parseNum(left.rest[1..]);
    if (right.n == null) return .{ .rest = right.rest, .mul = null };
    // std.debug.print("GOT RIGHT\n", .{});

    // )
    if (right.rest.len < 1) return .{ .rest = "", .mul = null };
    if (right.rest[0] != ')') return .{ .rest = right.rest[1..], .mul = null };
    // std.debug.print("GOT )\n", .{});

    return .{ .rest = right.rest[1..], .mul = Mul{ .left = left.n.?, .right = right.n.? } };
}

fn parseNum(input: []const u8) struct { rest: []const u8, n: ?u32 } {
    var r: u32 = 0;
    var i: u8 = 0;
    while (i < input.len and i < 3 and std.ascii.isDigit(input[i])) {
        r = r * 10 + input[i] - '0';
        i += 1;
    }
    if (i == 0) return .{ .rest = input, .n = null };
    return .{ .rest = input[i..], .n = r };
}

test "parseNum" {
    const r = parseNum("2340");
    try std.testing.expectEqual(234, r.n.?);
    try std.testing.expectEqualSlices(u8, "0", r.rest);
}

test "parseNumBad" {
    const r = parseNum("_2340");
    try std.testing.expectEqual(null, r.n);
    try std.testing.expectEqualSlices(u8, "_2340", r.rest);
}

test "parse" {
    const r = parseMul("xmul(2,4)we");
    try std.testing.expectEqual(Mul{ .left = 2, .right = 4 }, r.mul.?);
    try std.testing.expectEqualSlices(u8, "we", r.rest);
}

test "sample" {
    const problem: @This() = .{
        .input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))",
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(161, sol.p1);
    // try std.testing.expectEqual(4, sol.p2);
}
