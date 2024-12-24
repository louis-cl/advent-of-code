const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u64, p2: u32 };

const GateId = [3]u8;
const Op = enum {
    AND,
    OR,
    XOR,
};
const Gate = struct { op: Op, left: GateId, right: GateId };
const Circuit = struct {
    wires: std.AutoHashMap(GateId, bool),
    gates: std.AutoHashMap(GateId, Gate),
};

pub fn solve(this: *const @This()) !Solution {
    var circuit = Circuit{
        .gates = std.AutoHashMap(GateId, Gate).init(this.allocator), //
        .wires = std.AutoHashMap(GateId, bool).init(this.allocator),
    };
    defer circuit.gates.deinit();
    defer circuit.wires.deinit();

    var iter = mem.splitScalar(u8, this.input, '\n');
    // read wires
    while (iter.next()) |line| {
        if (line.len == 0) break;
        try circuit.wires.put(line[0..3].*, line[5] == '1');
    }
    while (iter.next()) |line| {
        if (line.len == 0) break;
        var gate_iter = mem.splitScalar(u8, line, ' ');
        const left: GateId = gate_iter.next().?[0..3].*;
        const op: Op = switch (gate_iter.next().?[0]) {
            'A' => .AND,
            'O' => .OR,
            'X' => .XOR,
            else => unreachable,
        };
        const right: GateId = gate_iter.next().?[0..3].*;
        _ = gate_iter.next().?; // ->
        const out: GateId = gate_iter.next().?[0..3].*;
        const gate = Gate{ .left = left, .right = right, .op = op };
        try circuit.gates.put(out, gate);
    }

    return Solution{ .p1 = try part1(&circuit), .p2 = 0 };
}

// PART2
// We know the circuit must add.
// We have 89 AND, 89 XOR, 133 OR
// 89 = 2 * 44 + 1
// 133 = 3 * 44 + 1
// we have 44 bits, this is a standard adder
// then all z bits must come from a XOR
// z12, z19, z37 are not XOR

// for each of these the wire doing x XOR y then find the gate doing XOR on that result. example:
// y12 XOR x12 -> jsb
// njf XOR jsb -> djg  (this is the only gate doing XOR with jsb)
// => djg should be z12

// What about the last swap ?
// look at each zN wire they are a XOR of two things:
// - xN XOR xY
// - the carry from N-1
// for z24 my input was doing a XOR of and OR (expected carry)
// and y24 AND x24 instead of y24 XOR y24

fn part1(circuit: *Circuit) !u64 {
    // need to run the circuit until all z wires are set
    var any_pending_z = true;
    while (any_pending_z) {
        any_pending_z = false;
        var it = circuit.gates.iterator();
        while (it.next()) |entry| {
            const id = entry.key_ptr.*;
            if (circuit.wires.get(id) != null) continue; // already done
            const gate = entry.value_ptr.*;
            if (circuit.wires.get(gate.left)) |left| {
                if (circuit.wires.get(gate.right)) |right| {
                    const val = switch (gate.op) {
                        .AND => left and right,
                        .OR => left or right,
                        .XOR => left != right,
                    };
                    try circuit.wires.put(id, val);
                    continue;
                }
            }
            if (id[0] == 'z') any_pending_z = true;
        }
    }
    // all the z gates are resolved,
    var result: u64 = 0;
    var next_id: GateId = .{ 'z', '0', '0' };
    var next_i: u8 = 0;
    var mask: u64 = 1;
    while (circuit.wires.get(next_id)) |z| {
        // std.debug.print("Got gate {s} with bool {any}\n", .{ next_id, z });
        if (z) result |= mask;
        mask = mask << 1;
        next_i += 1;
        if (next_i % 10 == 0) {
            next_id[1] += 1;
            next_id[2] = '0';
        } else {
            next_id[2] += 1;
        }
    }
    return result;
}

test "sample" {
    const input =
        \\x00: 1
        \\x01: 1
        \\x02: 1
        \\y00: 0
        \\y01: 1
        \\y02: 0
        \\
        \\x00 AND y00 -> z00
        \\x01 XOR y01 -> z01
        \\x02 OR y02 -> z02
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(4, sol.p1);
    // try std.testing.expectEqual(123, sol.p2);
}
