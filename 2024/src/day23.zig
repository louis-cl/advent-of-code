const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u32 };

const MAX_VERTICES = 26 * 26; // 2 lowercase letter
const ADJ = @Vector(MAX_VERTICES, u1);

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');
    var graph: []ADJ = try this.allocator.alloc(ADJ, MAX_VERTICES);
    @memset(graph, @splat(0));
    defer this.allocator.free(graph);

    var nodes: ADJ = @splat(0);
    while (iter.next()) |line| {
        if (line.len == 0) break;
        const left = vertex(line);
        const right = vertex(line[3..]);
        graph[left][right] = 1;
        graph[right][left] = 1;
        nodes[left] = 1;
        nodes[right] = 1;
    }
    return Solution{ .p1 = part1(graph), .p2 = part2(graph, nodes) };
}

fn part2(graph: []const ADJ, nodes: ADJ) u32 {
    const res = bk(graph, @splat(0), nodes, @splat(0)).?;
    for (0..graph.len) |i| {
        if (res[i] == 0) continue;
        std.debug.print("clique has {s}\n", .{name(i)});
    }
    return std.simd.countElementsWithValue(res, 1);
}

fn bk(graph: []const ADJ, in: ADJ, maybe: ADJ, out: ADJ) ?ADJ {
    if (std.simd.countElementsWithValue(maybe, 1) == 0 and std.simd.countElementsWithValue(out, 1) == 0) {
        return in;
    }
    var max_clique: ADJ = undefined;
    var max_clique_size: usize = 0;
    var current_maybe = maybe;
    var current_out = out;
    for (0..graph.len) |i| {
        if (current_maybe[i] == 0) continue;
        var new_in = in;
        new_in[i] = 1;
        if (bk(graph, new_in, current_maybe & graph[i], current_out & graph[i])) |res| {
            const size = std.simd.countElementsWithValue(res, 1);
            if (max_clique_size < size) {
                max_clique_size = size;
                max_clique = res;
            }
        }
        current_maybe[i] = 0;
        current_out[i] = 1;
    }
    return if (max_clique_size > 0) max_clique else null;
}

fn part1(graph: []ADJ) u32 {
    const n = graph.len;
    var res: u32 = 0;
    for (0..26) |i| {
        for (i..n) |j| {
            if (graph[i][j] == 0) continue;
            for (j..n) |k| {
                if (graph[i][k] == 1 and graph[j][k] == 1) res += 1;
            }
        }
    }
    return res;
}

fn name(i: usize) [2]u8 {
    var res: [2]u8 = undefined;
    res[0] = switch (i / 26) {
        0 => 't',
        't' - 'a' => 'a',
        else => |x| @intCast('a' + x),
    };
    res[1] = @intCast('a' + i % 26);
    return res;
}

fn vertex(a: []const u8) usize {
    // put the t- at the front by swapping with a-
    const first: usize = switch (a[0]) {
        'a' => 't' - 'a',
        't' => 0,
        else => a[0] - 'a',
    };
    return first * 26 + a[1] - 'a';
}

test "sample" {
    const input =
        \\kh-tc
        \\qp-kh
        \\de-cg
        \\ka-co
        \\yn-aq
        \\qp-ub
        \\cg-tb
        \\vc-aq
        \\tb-ka
        \\wh-tc
        \\yn-cg
        \\kh-ub
        \\ta-co
        \\de-co
        \\tc-td
        \\tb-wq
        \\wh-td
        \\ta-ka
        \\td-qp
        \\aq-cg
        \\wq-ub
        \\ub-vc
        \\de-ta
        \\wq-aq
        \\wq-vc
        \\wh-yn
        \\ka-de
        \\kh-ta
        \\co-tc
        \\wh-qp
        \\tb-vc
        \\td-yn
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(7, sol.p1);
    try std.testing.expectEqual(4, sol.p2);
}
