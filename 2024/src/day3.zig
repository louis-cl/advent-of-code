const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u32 };

const Mul = struct { left: u32, right: u32 };
const Instr = union(enum) {
    mul: Mul,
    do: struct {},
    dont: struct {},
};

pub fn solve(this: *const @This()) !Solution {
    var data = this.input;
    var p1: u32 = 0;
    var p2: u32 = 0;
    var active: bool = true;
    while (data.len > 0) {
        const instr = nextInstr(data);
        if (instr.instr == null) break;
        switch (instr.instr.?) {
            .mul => |m| {
                const val = m.left * m.right;
                p1 += val;
                if (active) p2 += val;
            },
            .do => active = true,
            .dont => active = false,
        }
        data = instr.rest;
    }

    return Solution{ .p1 = p1, .p2 = p2 };
}

fn nextInstr(input: []const u8) struct { rest: []const u8, instr: ?Instr } {
    var i: usize = 0;
    while (i < input.len) {
        const m = parseMul(input[i..]);
        if (m.mul) |r| {
            return .{ .rest = m.rest, .instr = Instr{ .mul = r } };
        }
        if (mem.startsWith(u8, input[i..], "do()")) {
            return .{ .rest = input[i + 4 ..], .instr = Instr{ .do = .{} } };
        }
        if (mem.startsWith(u8, input[i..], "don't()")) {
            return .{ .rest = input[i + 7 ..], .instr = Instr{ .dont = .{} } };
        }
        i += 1;
    }
    return .{ .rest = input, .instr = null };
}

fn parseMul(input: []const u8) struct { rest: []const u8, mul: ?Mul } {
    blk: {
        // mul(
        if (!mem.startsWith(u8, input, "mul(")) break :blk;

        // number
        const left = parseNum(input[4..]);
        if (left.n == null) break :blk;

        // ,
        if (left.rest.len < 1 or left.rest[0] != ',') break :blk;

        // number
        const right = parseNum(left.rest[1..]);
        if (right.n == null) break :blk;

        // )
        if (right.rest.len < 1 or right.rest[0] != ')') break :blk;

        return .{ .rest = right.rest[1..], .mul = Mul{ .left = left.n.?, .right = right.n.? } };
    }
    return .{ .rest = input, .mul = null };
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

test "parseMul" {
    const r = parseMul("mul(2,4)we");
    try std.testing.expectEqual(Mul{ .left = 2, .right = 4 }, r.mul.?);
    try std.testing.expectEqualSlices(u8, "we", r.rest);
}

test "parseMulPartial" {
    const r = parseMul("mul(");
    try std.testing.expectEqual(null, r.mul);
    try std.testing.expectEqualSlices(u8, "mul(", r.rest);
}

test "nextInstrMul" {
    const r = nextInstr("xmul(2,4)we");
    try std.testing.expectEqual(Mul{ .left = 2, .right = 4 }, r.instr.?.mul);
    try std.testing.expectEqualSlices(u8, "we", r.rest);
}

test "nextInstrDo" {
    const r = nextInstr("xmudo()we");
    try std.testing.expectEqual(Instr{ .do = .{} }, r.instr.?);
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
