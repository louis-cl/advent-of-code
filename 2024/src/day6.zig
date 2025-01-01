const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u32 };
const Cell = enum { block, walked, free };
const State = struct {
    x: i32,
    y: i32,
    dx: i8,
    dy: i8,
    fn next(self: *const State) State {
        return State{ .x = self.x + self.dx, .y = self.y + self.dy, .dx = self.dx, .dy = self.dy };
    }
    fn back(self: *const State) State {
        return State{ .x = self.x - self.dx, .y = self.y - self.dy, .dx = self.dx, .dy = self.dy };
    }
    fn turn(self: *const State) State {
        // rotate 90 deg clockwise (or counter because my basis is wrongly oriented...)
        return State{ .x = self.x, .y = self.y, .dx = self.dy, .dy = -self.dx };
    }
    fn dist(self: *const State, other: State) u32 {
        return @abs(self.x - other.x) + @abs(self.y - other.y);
    }
};

const Map = struct {
    blocks: []Cell,
    n: usize,

    pub fn get(self: *const Map, x: i32, y: i32) Cell {
        return self.blocks[@as(usize, @intCast(x)) * self.n + @as(usize, @intCast(y))];
    }

    pub fn set(self: *const Map, x: i32, y: i32, cell: Cell) void {
        self.blocks[@as(usize, @intCast(x)) * self.n + @as(usize, @intCast(y))] = cell;
    }

    pub fn contains(self: *const Map, x: i32, y: i32) bool {
        return x >= 0 and y >= 0 and x < self.n and y < self.n;
    }
};

pub fn solve(this: *const @This()) !Solution {
    var iter = mem.splitScalar(u8, this.input, '\n');
    // input is a square
    const n = iter.peek().?.len;
    const map = Map{
        .blocks = try this.allocator.alloc(Cell, n * n),
        .n = n,
    };
    defer this.allocator.free(map.blocks);

    var x: i32 = 0;
    var start: State = undefined;
    while (iter.next()) |line| {
        if (line.len == 0) break;
        for (line, 0..) |char, y| {
            switch (char) {
                '#' => map.set(x, @intCast(y), Cell.block),
                '^' => {
                    start = State{ .x = x, .y = @intCast(y), .dx = -1, .dy = 0 };
                    map.set(x, @intCast(y), Cell.free);
                },
                else => map.set(x, @intCast(y), Cell.free),
            }
        }
        x += 1;
    }
    return Solution{
        .p1 = part1(map, start),
        .p2 = try part2(this.allocator, map, start),
        // .p2 = 0,
    };
}

fn part1(map: Map, start: State) u32 {
    var p = start;
    var count: u32 = 0;
    while (true) {
        // std.debug.print("guard at {any}\n", .{p});
        const next = p.next();
        if (!map.contains(next.x, next.y)) break;
        switch (map.get(next.x, next.y)) {
            .block => p = p.turn(),
            .free => {
                p = next;
                count += 1;
                map.set(p.x, p.y, Cell.walked);
            },
            .walked => p = next,
        }
    }
    return count;
}

const Visited = struct {
    data: []u8,
    n: usize,

    fn encode(dx: i8, dy: i8) u8 {
        // when you wish direction was an enum...
        if (dx == 0 and dy == 1) {
            return 1;
        } else if (dx == 1 and dy == 0) {
            return 2;
        } else if (dx == 0 and dy == -1) {
            return 4;
        } else if (dx == -1 and dy == 0) {
            return 8;
        } else {
            unreachable;
        }
    }

    fn pos(self: *const Visited, state: State) usize {
        return @as(usize, @intCast(state.x)) * self.n + @as(usize, @intCast(state.y));
    }

    pub fn contains(self: *const Visited, state: State) bool {
        const cell = self.data[self.pos(state)];
        return (cell & encode(state.dx, state.dy)) != 0;
    }

    pub fn put(self: *Visited, state: State) void {
        self.data[self.pos(state)] |= encode(state.dx, state.dy);
    }

    pub fn clearRetainingCapacity(self: *Visited) void {
        @memset(self.data, 0);
    }
};

const BlockJumping = struct {
    next: std.AutoHashMap(State, State),

    fn init(allocator: mem.Allocator, map: Map) !@This() {
        var r = @This(){ .next = std.AutoHashMap(State, State).init(allocator) };
        for (0..map.n) |i| {
            for (0..map.n) |j| {
                if (map.get(@intCast(i), @intCast(j)) == .block) {
                    try r.process(map, i, j);
                }
            }
        }
        return r;
    }

    fn process(this: *@This(), map: Map, i: usize, j: usize) !void {
        // there's a # at i,j
        var state = State{ .x = @intCast(i), .y = @intCast(j), .dx = -1, .dy = 0 };
        for (0..4) |_| { // for each direction
            // std.debug.print("jump for rock at {any}\n", .{state});
            // walk back to face the # and turn
            var p = state.back().turn().next();
            while (map.contains(p.x, p.y)) : (p = p.next()) {
                if (map.get(p.x, p.y) == .block) {
                    try this.next.put(state, p);
                    // std.debug.print("\t found next at {any}\n", .{p});
                    break;
                }
            }
            state = state.turn();
        }
        // std.debug.print("\n", .{});
    }

    fn get(this: *const @This(), s: State) ?State {
        return this.next.get(s);
    }

    fn deinit(this: *@This()) void {
        this.next.deinit();
    }
};

fn part2(allocator: mem.Allocator, map: Map, start: State) !u32 {
    var p = start;

    var blocks = std.AutoHashMap([2]i32, void).init(allocator);
    defer blocks.deinit();

    var jumps = try BlockJumping.init(allocator, map);
    defer jumps.deinit();

    var visited = Visited{ .data = try allocator.alloc(u8, map.n * map.n), .n = map.n };
    defer allocator.free(visited.data);
    map.set(start.x, start.y, Cell.free); // prevent blocking the start
    while (true) {
        // std.debug.print("guard at {d},{d}\n", .{ p.x, p.y });
        const next = p.next();
        if (!map.contains(next.x, next.y)) break;
        switch (map.get(next.x, next.y)) {
            .block => p = p.turn(),
            .walked => { // try a rock
                if (!blocks.contains(.{ next.x, next.y })) {
                    // std.debug.print("try rock at {d},{d}\n", .{ next.x, next.y });
                    map.set(next.x, next.y, Cell.block);
                    visited.clearRetainingCapacity();
                    if (cycles(&visited, jumps, map, next)) {
                        // std.debug.print("block {any}\n", .{next});
                        try blocks.put(.{ next.x, next.y }, {});
                    }
                    map.set(next.x, next.y, Cell.free); // undo, mark free to not try again
                }
                p = next;
            },
            .free => p = next,
        }
    }
    return blocks.count();
}

const DEBUG = false;
inline fn print(comptime fmt: []const u8, args: anytype) void {
    if (DEBUG) std.debug.print(fmt, args);
}

fn cycles(visited: *Visited, jumps: BlockJumping, map: Map, start: State) bool {
    // true if walking from start with a rock in start would cycle
    const block = start;
    print("cycles for block at {any}\n", .{block});
    visited.put(block);
    // walk until next block to start jumping
    if (walk_until_block(map, start.back().turn())) |current| {
        var p = current;
        while (!visited.contains(p)) {
            print("\tvisiting {any}\n", .{p});
            visited.put(p);
            // can't use the jumps if we are at the block
            if (p.x == block.x and p.y == block.y) {
                const b = p.back();
                std.debug.assert(map.get(b.x, b.y) != .block);
                if (walk_until_block(map, p.back().turn().next())) |next| {
                    p = next;
                } else {
                    print("out after virtual block!\n", .{});
                    return false; // no block, we are out
                }
            }
            const next_block = hit_block(p, block);
            const next_jump = jumps.get(p);
            if (next_block != null and next_jump != null) {
                // pick closest
                if (next_block.?.dist(p) < next_jump.?.dist(p)) {
                    p = next_block.?;
                } else {
                    p = next_jump.?;
                }
            } else if (next_block) |next| {
                p = next;
            } else if (next_jump) |next| {
                p = next;
            } else {
                print("out!\n", .{});
                return false; // out of map
            }
        }
        print("cycled at {any}!\n", .{p});
        return true;
    }
    print("out from the start!\n", .{});
    return false; // out of the map
}

fn walk_until_block(map: Map, start: State) ?State {
    var p = start;
    while (map.contains(p.x, p.y)) : (p = p.next()) {
        if (map.get(p.x, p.y) == .block) return p;
    }
    return null;
}

fn hit_block(current: State, block: State) ?State {
    const p = current.back().turn();
    // will walking forward from p hit block ?
    if (std.math.order(block.x, p.x) != std.math.order(p.dx, 0) //
    or std.math.order(block.y, p.y) != std.math.order(p.dy, 0)) return null;
    return State{ .x = block.x, .y = block.y, .dx = p.dx, .dy = p.dy };
}

test "sample" {
    const input =
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(41, sol.p1);
    try std.testing.expectEqual(6, sol.p2);
}
