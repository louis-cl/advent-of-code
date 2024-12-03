const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u32 };

const Mul = struct { left: u32, right: u32 };
const Instr = union(enum) {
    mul: Mul,
    do,
    dont,
};

pub fn solve(this: *const @This()) !Solution {
    var data = this.input;
    var p1: u32 = 0;
    var p2: u32 = 0;
    var active: bool = true;
    while (nextInstr(data)) |res| {
        switch (res.instr) {
            .mul => |m| {
                const val = m.left * m.right;
                p1 += val;
                if (active) p2 += val;
            },
            .do => active = true,
            .dont => active = false,
        }
        data = res.rest;
    }

    return Solution{ .p1 = p1, .p2 = p2 };
}

fn nextInstr(input: []const u8) ?struct { rest: []const u8, instr: Instr } {
    var i: usize = 0;
    while (i < input.len) {
        if (parseMul(input[i..])) |m| {
            return .{ .rest = m.rest, .instr = Instr{ .mul = m.mul } };
        }
        if (mem.startsWith(u8, input[i..], "do()")) {
            return .{ .rest = input[i + 4 ..], .instr = Instr{ .do = {} } };
        }
        if (mem.startsWith(u8, input[i..], "don't()")) {
            return .{ .rest = input[i + 7 ..], .instr = Instr{ .dont = {} } };
        }
        i += 1;
    }
    return null;
}

fn parseMul(input: []const u8) ?struct { rest: []const u8, mul: Mul } {
    // mul(
    const rest = parseToken(input, "mul(");
    if (rest == null) return null;

    // number
    const left = parseNum(rest.?);
    if (left == null) return null;

    // ,
    if (!mem.startsWith(u8, left.?.rest, ",")) return null;

    // number
    const right = parseNum(left.?.rest[1..]);
    if (right == null) return null;

    // )
    const restP = parseToken(right.?.rest, ")");
    if (restP == null) return null;

    return .{ .rest = restP.?, .mul = Mul{ .left = left.?.n, .right = right.?.n } };
}

fn parseToken(input: []const u8, token: []const u8) ?[]const u8 {
    if (!mem.startsWith(u8, input, token)) return null;
    return input[token.len..];
}

fn parseNum(input: []const u8) ?struct { rest: []const u8, n: u32 } {
    var r: u32 = 0;
    var i: u8 = 0;
    while (i < input.len and i < 3 and std.ascii.isDigit(input[i])) {
        r = r * 10 + input[i] - '0';
        i += 1;
    }
    if (i == 0) return null;
    return .{ .rest = input[i..], .n = r };
}

test "parseNum" {
    const r = parseNum("2340").?;
    try std.testing.expectEqual(234, r.n);
    try std.testing.expectEqualSlices(u8, "0", r.rest);
}

test "parseNumBad" {
    const r = parseNum("_2340");
    try std.testing.expectEqual(null, r);
}

test "parseMul" {
    const r = parseMul("mul(2,4)we").?;
    try std.testing.expectEqual(Mul{ .left = 2, .right = 4 }, r.mul);
    try std.testing.expectEqualSlices(u8, "we", r.rest);
}

test "parseMulPartial" {
    const r = parseMul("mul(");
    try std.testing.expectEqual(null, r);
}

test "nextInstrMul" {
    const r = nextInstr("xmul(2,4)we").?;
    try std.testing.expectEqual(Mul{ .left = 2, .right = 4 }, r.instr.mul);
    try std.testing.expectEqualSlices(u8, "we", r.rest);
}

test "nextInstrDo" {
    const r = nextInstr("xmudo()we").?;
    try std.testing.expectEqual(Instr{ .do = {} }, r.instr);
    try std.testing.expectEqualSlices(u8, "we", r.rest);
}

test "sample" {
    const problem: @This() = .{
        .input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))",
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(161, sol.p1);
}

test "sample2" {
    const problem: @This() = .{
        .input = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))",
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(48, sol.p2);
}
