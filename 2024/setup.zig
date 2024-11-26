const std = @import("std");
const fs = std.fs;
const fmt = std.fmt;
const http = std.http;
const Allocator = std.mem.Allocator;
const config = @import("config");

pub const std_options: std.Options = .{
    .http_disable_tls = false,
};

const print = std.debug.print;

pub fn main() !void {
    print("Setup year {s}, day {s}\n", .{ config.year, config.day });

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    fetchInputFileIfNotPresent(
        allocator,
    ) catch |err| switch (err) {
        error.EnvironmentVariableNotFound => {
            print("AOC_SESSION_TOKEN environment variable not found, you need to set it to fetch input files from AoC Server.\n", .{});
            std.process.exit(1);
        },
        error.FailedToFetchInputFile => {
            print("Failed to fetch input file from AoC Server (Has the problem already been released?).\n", .{});
            std.process.exit(1);
        },
        else => {
            print("Error: {}\n", .{err});
            std.process.exit(1);
        },
    };

    try generateSourceFileIfNotPresent(allocator);
}

fn fetchInputFileIfNotPresent(allocator: Allocator) !void {
    const input_path = try fs.path.join(
        allocator,
        &[_][]const u8{
            config.input_dir,
            try fmt.allocPrint(
                allocator,
                "day{s}.txt",
                .{config.day},
            ),
        },
    );
    // If file is already present, return the path
    if (fs.cwd().access(input_path, .{})) |_| {
        return;
    } else |_| { // Else, fetch from AoC API, save to disk, and then return the path
        const session_token = try std.process.getEnvVarOwned(
            allocator,
            "AOC_SESSION_TOKEN",
        );

        var http_client = http.Client{
            .allocator = allocator,
        };
        defer http_client.deinit();

        var response = std.ArrayList(u8).init(allocator);
        defer response.deinit();

        const res = try http_client.fetch(.{
            .location = .{
                .url = try fmt.allocPrint(
                    allocator,
                    "https://adventofcode.com/{s}/day/{s}/input",
                    .{ config.year, config.day },
                ),
            },
            .method = .GET,
            .extra_headers = &[_]http.Header{
                .{
                    .name = "Cookie",
                    .value = try fmt.allocPrint(
                        allocator,
                        "session={s}",
                        .{session_token},
                    ),
                },
            },
            .response_storage = .{ .dynamic = &response },
        });

        if (res.status != .ok)
            return error.FailedToFetchInputFile;

        // Save to disk
        const dir = try fs.cwd().makeOpenPath(
            fs.path.dirname(input_path).?,
            .{},
        );
        const file = try dir.createFile(fs.path.basename(input_path), .{});
        defer file.close();
        try file.writeAll(response.items);
    }
}

fn generateSourceFileIfNotPresent(allocator: Allocator) !void {
    const src_path = try fs.path.join(
        allocator,
        &[_][]const u8{
            config.src_dir,
            try fmt.allocPrint(
                allocator,
                "day{s}.zig",
                .{config.day},
            ),
        },
    );

    // If file is already present, do nothing
    if (fs.cwd().access(src_path, .{})) |_| {
        return;
    } else |_| { // Else, create new file with template
        const template =
            \\const std = @import("std");
            \\const mem = std.mem;
            \\
            \\input: []const u8,
            \\allocator: mem.Allocator,
            \\
            \\pub fn part1(this: *const @This()) !?i64 {
            \\    _ = this;
            \\    return null;
            \\}
            \\
            \\pub fn part2(this: *const @This()) !?i64 {
            \\    _ = this;
            \\    return null;
            \\}
            \\
            \\test "it should do nothing" {
            \\    const problem: @This() = .{
            \\        .input = "",
            \\        .allocator = std.testing.allocator,
            \\    };
            \\
            \\    try std.testing.expectEqual(null, try problem.part1());
            \\    try std.testing.expectEqual(null, try problem.part2());
            \\}
        ;
        const dir = try fs.cwd().makeOpenPath(
            fs.path.dirname(src_path).?,
            .{},
        );
        const file = try dir.createFile(fs.path.basename(src_path), .{});
        defer file.close();
        try file.writeAll(template);
    }
}
