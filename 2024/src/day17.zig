const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: []u8, p2: i64 };

const Program = struct {
    // instructions
    ip: usize,
    instr: []u3,
    // registers
    a: i64,
    b: i64,
    c: i64,

    fn reset(this: *@This(), a: i64) void {
        this.ip = 0;
        this.a = a;
        this.b = 0;
        this.c = 0;
    }

    fn isHalted(this: *const @This()) bool {
        return this.ip >= this.instr.len;
    }

    fn combo(this: *@This(), literal: u3) i64 {
        return switch (literal) {
            0, 1, 2, 3 => literal,
            4 => this.a,
            5 => this.b,
            6 => this.c,
            7 => unreachable,
        };
    }

    fn step(this: *@This()) ?i64 {
        const op = this.instr[this.ip];
        const arg = this.instr[this.ip + 1];
        this.ip += 2;
        var out: ?i64 = null;
        switch (op) {
            0 => this.a = this.a >> @as(u5, @intCast(this.combo(arg))),
            1 => this.b ^= arg,
            2 => this.b = this.combo(arg) & 0b0111,
            3 => {
                if (this.a != 0) this.ip = arg;
            },
            4 => this.b ^= this.c,
            5 => out = this.combo(arg) & 0b0111,
            6 => this.b = this.a >> @as(u5, @intCast(this.combo(arg))),
            7 => this.c = this.a >> @as(u5, @intCast(this.combo(arg))),
        }
        return out;
    }

    pub fn nextOut(this: *@This()) i64 {
        while (!this.isHalted()) {
            if (this.step()) |out| return out;
        }
        unreachable;
    }
};

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');
    const a = try readRegister(iter.next().?);
    const b = try readRegister(iter.next().?);
    const c = try readRegister(iter.next().?);
    _ = iter.next().?; // empty line
    var prog = Program{
        .ip = 0,
        .a = a,
        .b = b,
        .c = c,
        .instr = try readProgram(this.allocator, iter.next().?),
    };
    defer this.allocator.free(prog.instr);
    // std.debug.print("\n{any}\n", .{prog});
    return Solution{ .p1 = try part1(this.allocator, &prog), .p2 = part2(&prog) };
}

fn part1(allocator: mem.Allocator, prog: *Program) ![]u8 {
    var output = std.ArrayList(u8).init(allocator);
    defer output.deinit();
    while (!prog.isHalted()) {
        if (prog.step()) |out| {
            if (output.items.len != 0) try output.writer().writeByte(',');
            try output.writer().print("{d}", .{out});
        }
    }
    return try std.fmt.allocPrint(allocator, "{s}", .{output.items});
}

fn readRegister(line: []const u8) !i64 {
    var iter = mem.splitScalar(u8, line, ' ');
    _ = iter.next().?; // "Register"
    _ = iter.next().?; // "A:"
    return try std.fmt.parseUnsigned(i64, iter.next().?, 10);
}

fn readProgram(allocator: mem.Allocator, line: []const u8) ![]u3 {
    const nums = line[9..]; // skip "Program: "
    std.debug.assert(nums.len % 2 == 1);
    var res = try allocator.alloc(u3, nums.len / 2 + 1);
    var i: usize = 0;
    while (i < res.len) : (i += 1) res[i] = @intCast(nums[2 * i] - '0');
    return res;
}

fn part2(prog: *Program) i64 {
    // program instructions
    // do:
    //    b = a % 8 ^ 2
    //    c = a >> b
    //    b = b ^ c ^ 3
    //    out(b % 8)
    //    a = a >> 3
    // while (a != 0)

    // each loop prints some scramble of a
    // a >> 3 each loop
    // loop stops when a is 0
    // no state persists in b or c across loops

    // search backwards to make program reach 0 and print the last digit, recur
    return search(prog, 0, prog.instr.len - 1).?;
}

fn search(prog: *Program, a: i64, target: usize) ?i64 {
    const desired = prog.instr[target];
    for (0..8) |x| {
        const new_a: i64 = a + @as(i64, @intCast(x));
        prog.reset(new_a);
        if (prog.nextOut() == desired) {
            // std.debug.print("found {d} to output {d}\n", .{ new_a, desired });
            if (target == 0) return new_a;
            if (search(prog, new_a * 8, target - 1)) |res| return res;
        }
    }
    return null;
}

test "sample" {
    const input =
        \\Register A: 729
        \\Register B: 0
        \\Register C: 0
        \\
        \\Program: 0,1,5,4,3,0
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqualStrings("4,6,3,5,6,3,5,2,1,0", sol.p1);
    std.testing.allocator.free(sol.p1);
}

test "sample2" {
    const input =
        \\Register A: 2024
        \\Register B: 0
        \\Register C: 0
        \\
        \\Program: 0,3,5,4,3,0
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    std.testing.allocator.free(sol.p1);
    try std.testing.expectEqual(117440, sol.p2);
}
