const builtin = @import("builtin");
comptime {
    const required_zig = "0.14.0-dev";
    const current_zig = builtin.zig_version;
    const min_zig = std.SemanticVersion.parse(required_zig) catch unreachable;
    if (current_zig.order(min_zig) == .lt) {
        const error_message =
            \\Sorry, it looks like your version of zig is too old. :-(
            \\
            \\aoc.zig requires development build {}
            \\
            \\Please download a development ("master") build from
            \\
            \\https://ziglang.org/download/
            \\
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

var YEAR: []const u8 = "2023";
var DAY: []const u8 = undefined;
const INPUT_DIR = "input";
const SRC_DIR = "src";

pub fn build(b: *Build) !void {
    // Targets
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "aoc.zig",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    DAY = b.option(
        []const u8,
        "day",
        "The day of the Advent of Code challenge",
    ) orelse unreachable;

    const options = b.addOptions();
    options.addOption([]const u8, "year", YEAR);
    options.addOption([]const u8, "day", DAY);
    options.addOption([]const u8, "input_dir", INPUT_DIR);
    options.addOption([]const u8, "src_dir", SRC_DIR);

    exe.root_module.addAnonymousImport(
        "problem",
        .{
            .root_source_file = b.path(
                try fs.path.join(
                    b.allocator,
                    &[_][]const u8{
                        SRC_DIR,
                        try fmt.allocPrint(
                            b.allocator,
                            "day{s}.zig",
                            .{DAY},
                        ),
                    },
                ),
            ),
        },
    );
    exe.root_module.addAnonymousImport(
        "input",
        .{
            .root_source_file = b.path(
                try fs.path.join(
                    b.allocator,
                    &[_][]const u8{
                        INPUT_DIR,
                        try fmt.allocPrint(
                            b.allocator,
                            "day{s}.txt",
                            .{DAY},
                        ),
                    },
                ),
            ),
        },
    );

    // Setup Step:
    // - File -> ./input/day{n}.txt. If not exist on disk, fetch from AoC API, save to disk, and then read.
    // - File -> ./src/day{n}.zig. If not exist on disk, Create new file with template.
    const setup_step = b.step(
        "setup",
        "Fetch inputs and create source files for the requested year and day",
    );
    const setup_exe = b.addExecutable(.{
        .name = "setup",
        .root_source_file = b.path("setup.zig"),
        .target = target,
        .optimize = .ReleaseSafe,
    });
    setup_exe.root_module.addOptions("config", options);

    const run_setup = b.addRunArtifact(setup_exe);
    run_setup.setCwd(b.path("")); // This could probably be done in a more idiomatic way

    setup_step.dependOn(&run_setup.step);

    // install
    b.installArtifact(exe);

    // run
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // test
    const problem_unit_tests = b.addTest(.{
        .root_source_file = b.path(
            try fs.path.join(
                b.allocator,
                &[_][]const u8{
                    SRC_DIR,
                    try fmt.allocPrint(
                        b.allocator,
                        "day{s}.zig",
                        .{DAY},
                    ),
                },
            ),
        ),
        .target = target,
        .optimize = optimize,
    });
    const run_lib_unit_tests = b.addRunArtifact(problem_unit_tests);
    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);

    // clean
    const clean_step = b.step("clean", "Remove build artifacts");
    clean_step.dependOn(&b.addRemoveDirTree(b.path(fs.path.basename(b.install_path))).step);

    // in windows, you cannot delete a running executable 😥
    if (builtin.os.tag != .windows)
        clean_step.dependOn(&b.addRemoveDirTree(b.path(".zig-cache")).step);
}
