# Zig solutions to advent of code 2024

Template adapted from https://github.com/Tomcat-42/aoc.zig-template
Change YEAR in build.zig if needed, currently hardcoded to 2024.

Run `zig build -Dday=1 setup` to download input for day 1 and generate a day1.zig file
Run `zig build -Dday=1 run` to run day1.zig
Run `zig build -Dday=1 test` to run tests in day1.zig

Build day1 with `zig build -Dday=1 -Doptimize=ReleaseFast`
Run executable with `./zig-out/bin/aoc.zig`
Benchmark with `hyperfine --shell=none --warmup 3 './zig-out/bin/aoc.zig`

A makefile simplifies these into:
- make setup_1
- make run_1
- make test_1
- make perf_1

# Let's aim for performance
Template is embedding the input in the binary, so we are not measuring IO time for input read.
Data can be reused between part1 and part2.


# Performance results

## Day 1
commit 7998070:
  Time (mean ± σ):       1.7 ms ±   0.3 ms    [User: 0.8 ms, System: 0.6 ms]
  Range (min … max):     0.9 ms …   2.4 ms    2075 runs
commit 2d45ea0: run part1 and part2 in one go
  Time (mean ± σ):       1.6 ms ±   0.3 ms    [User: 0.7 ms, System: 0.6 ms]
  Range (min … max):     0.8 ms …   2.6 ms    2145 runs
commit 292f465: avoid hashmap in part2, leverage sorted input
  Time (mean ± σ):       1.4 ms ±   0.2 ms    [User: 0.5 ms, System: 0.6 ms]
  Range (min … max):     0.6 ms …   2.0 ms    2570 runs