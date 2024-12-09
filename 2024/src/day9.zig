const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u64, p2: u64 };

// input is assumed without \n at the end
pub fn solve(this: *const @This()) !Solution {
    return Solution{ .p1 = part1(this.allocator, this.input), .p2 = part2(this.allocator, this.input) };
}

const Chunk = struct {
    position: usize,
    size: u8,
    pub fn positionSum(this: *const Chunk) u64 {
        std.debug.assert(this.size > 0);
        const n = this.size;
        return (n - 1) * n / 2 + this.position * n;
    }
};

fn part1(allocator: mem.Allocator, disk: []const u8) u64 {
    std.debug.assert(disk.len % 2 == 1); // make sure last number is a file
    const n = (disk.len - 1) / 2;
    var files: []Chunk = allocator.alloc(Chunk, n + 1) catch unreachable;
    var spaces: []Chunk = allocator.alloc(Chunk, n) catch unreachable;
    defer allocator.free(files);
    defer allocator.free(spaces);
    var position: usize = 0;
    for (disk, 0..) |c, i| {
        const chunk = Chunk{ .position = position, .size = c - '0' };
        if (i % 2 == 0) files[i / 2] = chunk else spaces[i / 2] = chunk;
        position += chunk.size;
    }

    var checksum: u64 = 0;
    var next_space: usize = 0;
    var next_file = files.len - 1;
    while (next_space < next_file) {
        const space = spaces[next_space].size;
        if (space == 0) {
            next_space += 1;
            continue;
        }
        const file = files[next_file].size;
        const moved = @min(space, file);
        const chunk = Chunk{ .position = spaces[next_space].position, .size = moved };
        checksum += chunk.positionSum() * next_file;
        if (moved == space) next_space += 1 else {
            spaces[next_space].size -= moved;
            spaces[next_space].position += moved;
        }
        if (moved == file) next_file -= 1 else files[next_file].size -= moved;
    }
    for (0..next_file + 1) |i| {
        checksum += files[i].positionSum() * i;
    }

    //     var space = this.disk[2 * this.id_left - 1];
    // while (space > 0 and this.id_right >= this.id_left) {
    //     const size = this.fileSize(this.id_right);
    //     const fill_size = @min(space, size);
    //     space -= fill_size;
    //     this.addChecksum(this.id_right, fill_size);
    //     if (fill_size == size) {
    //         this.id_right -= 1;
    //     } else {
    //         this.disk[2 * this.id_right] = size - fill_size;
    //     }
    // }

    return checksum;
}

fn part2(allocator: mem.Allocator, disk: []const u8) u64 {
    std.debug.assert(disk.len % 2 == 1); // make sure last block is a file
    const n = (disk.len - 1) / 2;
    var files: []Chunk = allocator.alloc(Chunk, n + 1) catch unreachable;
    var spaces: []Chunk = allocator.alloc(Chunk, n) catch unreachable;
    defer allocator.free(files);
    defer allocator.free(spaces);
    var position: usize = 0;
    for (disk, 0..) |c, i| {
        const chunk = Chunk{ .position = position, .size = c - '0' };
        if (i % 2 == 0) files[i / 2] = chunk else spaces[i / 2] = chunk;
        position += chunk.size;
    }

    var checksum: u64 = 0;
    var id = files.len - 1;
    while (true) : (id -= 1) {
        // find space for file id
        const size = files[id].size;
        var sp: usize = 0;
        while (sp < id and spaces[sp].size < size) sp += 1;
        if (sp < id) { // move file id to space sp
            // std.debug.print("file {d} goes to space {d}\n", .{ id, sp });
            files[id].position = spaces[sp].position;
            spaces[sp].size -= files[id].size;
            spaces[sp].position += files[id].size;
        }
        checksum += id * files[id].positionSum();
        if (id == 0) break; // because id is usize it can't go negative
    }
    return checksum;
}

test "sample" {
    const problem: @This() = .{
        .input = "2333133121414131402",
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(1928, sol.p1);
    try std.testing.expectEqual(2858, sol.p2);
}
