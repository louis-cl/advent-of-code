const std = @import("std");
const fs = std.fs;
const io = std.io;
const heap = std.heap;

const Problem = @import("problem");

pub fn main() !void {
    const stdout = io.getStdOut().writer();

    var arena = heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const problem = Problem{
        .input = @embedFile("input"),
        .allocator = allocator,
    };

    const sol = try problem.solve();
    try stdout.print(switch (@TypeOf(sol.p1)) {
        []const u8 => "{s}",
        else => "{any}",
    } ++ "\n", .{sol.p1});

    try stdout.print(switch (@TypeOf(sol.p2)) {
        []const u8 => "{s}",
        else => "{any}",
    } ++ "\n", .{sol.p2});
}
