const builtin = @import("builtin");
comptime {
    const current_zig = builtin.zig_version;
    const min_zig = std.SemanticVersion.parse("0.14.0-dev") catch unreachable;
    if (current_zig.order(min_zig) == .lt) {
        const error_message =
            \\Sorry, it looks like your version of zig is too old. :-(
            \\aoc.zig requires development build {}
            \\Please download a development ("master") build from
            \\https://ziglang.org/download/
            \\
        ;
        @compileError(std.fmt.comptimePrint(error_message, .{min_zig}));
    }
}

const std = @import("std");
const fs = std.fs;
const fmt = std.fmt;

const Build = std.Build;
const LazyPath = Build.LazyPath;
const Step = Build.Step;
const Allocator = std.mem.Allocator;
const print = std.debug.print;

var DAY: []const u8 = undefined;
const INPUT_DIR = "input";
const SRC_DIR = "src";

pub fn build(b: *Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    for (1..26) |day| {
        const dayName = b.fmt("day{d}", .{day});
        const zigFile = b.fmt("src/{s}.zig", .{dayName});

        // executable
        const exe = b.addExecutable(.{
            .name = dayName,
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        });
        exe.root_module.addAnonymousImport("problem", .{
            .root_source_file = b.path(zigFile),
        });
        exe.root_module.addAnonymousImport("input", .{ .root_source_file = b.path(b.fmt("input/{s}.txt", .{dayName})) });
        // b.addInstallArtifact(exe, .{});

        // test
        const build_test = b.addTest(.{
            .root_source_file = b.path(zigFile),
            .target = target,
            .optimize = optimize,
        });
        const run_test = b.addRunArtifact(build_test);
        const test_step = b.step(b.fmt("test{d}", .{day}), b.fmt("Run tests for {s}", .{dayName}));
        test_step.dependOn(&run_test.step);

        // run
        const run_cmd = b.addRunArtifact(exe);
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        const run_step = b.step(dayName, b.fmt("Run {s}", .{dayName}));
        run_step.dependOn(&run_cmd.step);
    }

    // clean
    const clean_step = b.step("clean", "Remove build artifacts");
    clean_step.dependOn(&b.addRemoveDirTree(b.path(fs.path.basename(b.install_path))).step);

    // in windows, you cannot delete a running executable 😥
    if (builtin.os.tag != .windows)
        clean_step.dependOn(&b.addRemoveDirTree(b.path(".zig-cache")).step);
}
