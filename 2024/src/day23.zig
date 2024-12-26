const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u32 };

const MAX_VERTICES = 26 * 26; // 2 lowercase letter
const NodeSet = std.AutoHashMap(usize, void);

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

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');
    var graph: []NodeSet = try this.allocator.alloc(NodeSet, MAX_VERTICES);
    for (0..MAX_VERTICES) |i| graph[i] = NodeSet.init(this.allocator);
    defer {
        for (0..MAX_VERTICES) |i| graph[i].deinit();
        this.allocator.free(graph);
    }

    while (iter.next()) |line| {
        if (line.len == 0) break;
        const left = vertex(line);
        const right = vertex(line[3..]);
        try graph[left].put(right, {});
        try graph[right].put(left, {});
    }
    return Solution{
        .p1 = part1(graph), //
        .p2 = try part2(graph),
    };
}

const MaxClique = struct {
    best: NodeSet,
    graph: []const NodeSet,
    fn find(graph: []const NodeSet) !MaxClique {
        var empty = NodeSet.init(graph[0].allocator);
        defer empty.deinit();
        var c = MaxClique{ .best = try empty.clone(), .graph = graph };
        var nodes = try empty.clone();
        // nodes.ensureTotalCapacity(MAX_VERTICES);
        defer nodes.deinit();
        for (graph, 0..) |adj, i| {
            if (adj.count() > 0) try nodes.put(i, {});
        }
        try c.clique(&empty, &nodes);
        return c;
    }

    fn clique(this: *@This(), c: *NodeSet, p: *NodeSet) !void {
        if (c.count() > this.best.count()) {
            this.best.deinit();
            this.best = try c.clone();
        }
        if (c.count() + p.count() <= this.best.count()) return;
        var current_p = try p.clone();
        defer current_p.deinit();
        var it = p.keyIterator();
        while (it.next()) |next| {
            // clique(c + next, current_p & neighbours(next))
            _ = current_p.remove(next.*);
            try c.put(next.*, {});
            var p2 = try intersection(&current_p, &this.graph[next.*]);
            defer p2.deinit();
            try this.clique(c, &p2);
            _ = c.remove(next.*);
        }
    }

    fn intersection(a: *const NodeSet, b: *const NodeSet) !NodeSet {
        if (b.count() < a.count()) return intersection(b, a);
        var res = try a.clone();
        var it = a.keyIterator();
        while (it.next()) |v| {
            if (!b.contains(v.*)) _ = res.remove(v.*);
        }
        return res;
    }
};

fn part2(graph: []const NodeSet) !u32 {
    var max = try MaxClique.find(graph);
    var it = max.best.keyIterator();
    while (it.next()) |v| {
        std.debug.print("max clique contains {s}\n", .{name(v.*)});
    }
    const res = max.best.count();
    max.best.deinit();
    return res;
}

fn part1(graph: []const NodeSet) u32 {
    const n = graph.len;
    var res: u32 = 0;
    for (0..26) |i| { // only t
        for (i..n) |j| {
            if (!graph[i].contains(j)) continue;
            for (j..n) |k| {
                if (graph[i].contains(k) and graph[j].contains(k)) res += 1;
            }
        }
    }
    return res;
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
