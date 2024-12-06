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

## Day 2
commit 736751d:
  Time (mean ± σ):       1.4 ms ±   0.2 ms    [User: 0.5 ms, System: 0.6 ms]
  Range (min … max):     0.6 ms …   1.9 ms    2860 runs
commit b6d60de: write my own parse int
  Time (mean ± σ):       1.3 ms ±   0.1 ms    [User: 0.4 ms, System: 0.6 ms]
  Range (min … max):     0.9 ms …   1.8 ms    2233 runs
commit d135adf: use array of 8 pos instead of arraylist
  Time (mean ± σ):       1.2 ms ±   0.3 ms    [User: 0.4 ms, System: 0.5 ms]
  Range (min … max):     0.5 ms …   2.0 ms    2844 runs

## Day 3
commit 63e4eac:
  Time (mean ± σ):       1.0 ms ±   0.2 ms    [User: 0.3 ms, System: 0.5 ms]
  Range (min … max):     0.5 ms …   1.6 ms    3187 runs
commit c3ec2e1: lifting optional one level (no impact)
  Time (mean ± σ):       1.0 ms ±   0.1 ms    [User: 0.3 ms, System: 0.5 ms]
  Range (min … max):     0.5 ms …   1.7 ms    2653 runs

## Day 4
commit e0021f7:
  Time (mean ± σ):       1.8 ms ±   0.3 ms    [User: 1.0 ms, System: 0.5 ms]
  Range (min … max):     0.9 ms …   2.7 ms    1729 runs

## Day 5
commit 6fc6c4c:
  Time (mean ± σ):       1.2 ms ±   0.2 ms    [User: 0.3 ms, System: 0.6 ms]
  Range (min … max):     0.5 ms …   2.1 ms    2850 runs

## Day 6
commit 1478536: done without the optimize flags, otherwise after 12min it didn't finish 1 warmup run
  Time (mean ± σ):     21.795 s ±  0.196 s    [User: 21.658 s, System: 0.136 s]
  Range (min … max):   21.576 s … 22.251 s    10 runs
commit baa2d7e: do not retry rock position, allows to continue path instead of starting from scratch
  Time (mean ± σ):     14.670 s ±  0.081 s    [User: 14.575 s, System: 0.094 s]
  Range (min … max):   14.504 s … 14.824 s    10 runs
