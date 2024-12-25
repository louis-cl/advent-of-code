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

**commit 7998070**
```
Time (mean ± σ): 1.7 ms ± 0.3 ms [User: 0.8 ms, System: 0.6 ms]
Range (min … max): 0.9 ms … 2.4 ms (2075 runs)
```
**commit 2d45ea0** run part1 and part2 in one go
```
Time (mean ± σ): 1.6 ms ± 0.3 ms [User: 0.7 ms, System: 0.6 ms]
Range (min … max): 0.8 ms … 2.6 ms (2145 runs)
```

**commit 292f465** avoid hashmap in part2, leverage sorted input
```
Time (mean ± σ): 1.4 ms ± 0.2 ms [User: 0.5 ms, System: 0.6 ms]
Range (min … max): 0.6 ms … 2.0 ms (2570 runs)
```
## Day 2

**commit 736751d**
```
Time (mean ± σ): 1.4 ms ± 0.2 ms [User: 0.5 ms, System: 0.6 ms]
Range (min … max): 0.6 ms … 1.9 ms (2860 runs)
```
**commit b6d60de** write my own parse int
```
Time (mean ± σ): 1.3 ms ± 0.1 ms [User: 0.4 ms, System: 0.6 ms]
Range (min … max): 0.9 ms … 1.8 ms (2233 runs)
```
**commit d135adf** use array of 8 pos instead of arraylist
```
Time (mean ± σ): 1.2 ms ± 0.3 ms [User: 0.4 ms, System: 0.5 ms]
Range (min … max): 0.5 ms … 2.0 ms (2844 runs)
```

## Day 3

**commit 63e4eac**
```
Time (mean ± σ): 1.0 ms ± 0.2 ms [User: 0.3 ms, System: 0.5 ms]
Range (min … max): 0.5 ms … 1.6 ms (3187 runs)
```
**commit c3ec2e1** lifting optional one level (no impact)
```
Time (mean ± σ): 1.0 ms ± 0.1 ms [User: 0.3 ms, System: 0.5 ms]
Range (min … max): 0.5 ms … 1.7 ms (2653 runs)
```

## Day 4

**commit e0021f7**
```
Time (mean ± σ): 1.8 ms ± 0.3 ms [User: 1.0 ms, System: 0.5 ms]
Range (min … max): 0.9 ms … 2.7 ms (1729 runs)
```

## Day 5

**commit 6fc6c4c**
```
Time (mean ± σ): 1.2 ms ± 0.2 ms [User: 0.3 ms, System: 0.6 ms]
Range (min … max): 0.5 ms … 2.1 ms (2850 runs)
```

## Day 6

**commit 1478536** done with release safe flag, otherwise after 12min it didn't finish 1 warmup run
```
Time (mean ± σ): 6.386 s ± 0.357 s [User: 6.144 s, System: 0.242 s]
Range (min … max): 6.020 s … 6.872 s (10 runs)
```
**commit baa2d7e** do not retry rock position, allows to continue path instead of starting from scratch
```
Time (mean ± σ): 2.183 s ± 0.092 s [User: 2.098 s, System: 0.084 s]
Range (min … max): 2.081 s … 2.366 s (10 runs)
```
**commit 3390ebe** reuse hashmap in cycles check instead of creating a new one
```
Time (mean ± σ): 840.2 ms ± 41.6 ms [User: 839.7 ms, System: 0.4 ms]
Range (min … max): 789.6 ms … 879.2 ms (10 runs)
```
**commit c465f59** replace hashmap for visited by an array
```
Time (mean ± σ): 60.8 ms ± 1.7 ms [User: 60.0 ms, System: 0.5 ms]
Range (min … max): 59.6 ms … 67.8 ms (49 runs)
```
**commit cf59148** done with releaseFast after fixing memory initialization
```
Time (mean ± σ): 22.0 ms ± 0.3 ms [User: 21.4 ms, System: 0.4 ms]
Range (min … max): 21.7 ms … 23.6 ms (138 runs)
```

## Day 7

**commit 89f9849**
```
Time (mean ± σ): 86.9 ms ± 1.8 ms [User: 86.1 ms, System: 0.5 ms]
Range (min … max): 85.7 ms … 93.7 ms (34 runs)
```
**commit 41f029d** search from the end to prune scenarios
```
Time (mean ± σ): 1.9 ms ± 0.4 ms [User: 1.1 ms, System: 0.5 ms]
Range (min … max): 1.0 ms … 2.9 ms (1574 runs)
```

## Day 8

**commit 10b473b**
```
Time (mean ± σ): 1.3 ms ± 0.2 ms [User: 0.3 ms, System: 0.7 ms]
Range (min … max): 0.5 ms … 2.0 ms (3122 runs)
```
**commit 3fec575** hashmap → array
```
Time (mean ± σ): 707.9 µs ± 275.3 µs [User: 234.8 µs, System: 284.1 µs]
Range (min … max): 252.1 µs … 1437.7 µs (6009 runs)
```

## Day 9

**commit 4819ad9**
```
Time (mean ± σ): 11.5 ms ± 1.4 ms [User: 11.0 ms, System: 0.4 ms]
Range (min … max): 10.5 ms … 17.4 ms (273 runs)
```
**commit 3cbae5e** parse and allocate once (with memcpy), interestingly not improving much
```
Time (mean ± σ): 11.4 ms ± 1.2 ms [User: 10.8 ms, System: 0.4 ms]
Range (min … max): 10.5 ms … 16.9 ms (198 runs)
```
**commit 7652b4d** failing to find a space for file size S → we will fail for size ≥ S
```
Time (mean ± σ): 6.2 ms ± 1.5 ms [User: 5.6 ms, System: 0.4 ms]
Range (min … max): 3.3 ms … 14.1 ms (470 runs)
```
**commit b9b3d37** finding a space for size S at index x → next space of size ≥ S (if exists) is at index > x 
```
Time (mean ± σ): 1.3 ms ± 0.5 ms [User: 0.5 ms, System: 0.7 ms]
Range (min … max): 0.6 ms … 2.7 ms (4005 runs)
```

## Day 10

**commit 691edaf**
```
Time (mean ± σ): 900.7 µs ± 429.5 µs [User: 491.3 µs, System: 262.1 µs]
Range (min … max): 296.2 µs … 2553.1 µs (5473 runs)
```
**commit ab874c6** use index instead of map
```
Time (mean ± σ):     616.6 µs ± 190.2 µs    [User: 383.6 µs, System: 132.3 µs]
Range (min … max):   346.8 µs … 1886.1 µs    4816 runs
```

## Day 11

**commit 6d7bc68**
```
Time (mean ± σ):      13.4 ms ±   1.3 ms    [User: 10.9 ms, System: 2.3 ms]
Range (min … max):     9.9 ms …  17.5 ms    233 runs
```

## Day 12
**commit 811993d**
```
Time (mean ± σ):       2.0 ms ±   0.8 ms    [User: 1.6 ms, System: 0.3 ms]
Range (min … max):     1.3 ms …   5.5 ms    744 runs
```

## Day 13
**commit 3f09441**
```
Time (mean ± σ):     529.4 µs ± 292.6 µs    [User: 222.7 µs, System: 162.7 µs]
Range (min … max):   162.9 µs … 1519.5 µs    9435 runs
```

## Day 14
**commit dfbb2ca**
```
Time (mean ± σ):      31.2 ms ±   0.2 ms    [User: 26.7 ms, System: 4.3 ms]
Range (min … max):    31.0 ms …  32.4 ms    95 runs
```

## Day 15
**commit 4018a29**
```
Time (mean ± σ):       1.3 ms ±   0.6 ms    [User: 1.0 ms, System: 0.2 ms]
Range (min … max):     0.8 ms …   3.6 ms    2870 runs
```

## Day 16
**commit 0c44deb**
```
Time (mean ± σ):       4.3 ms ±   1.1 ms    [User: 3.8 ms, System: 0.3 ms]
Range (min … max):     2.9 ms …  11.5 ms    815 runs
```

## Day 17
**commit 5533a6f**
```
Time (mean ± σ):     745.4 µs ± 275.9 µs    [User: 227.5 µs, System: 341.7 µs]
Range (min … max):   213.1 µs … 3176.1 µs    7685 runs
```

## Day 18
**commit 6216f24**
```
Time (mean ± σ):     990.5 µs ± 435.0 µs    [User: 589.1 µs, System: 266.9 µs]
Range (min … max):   378.2 µs … 2735.0 µs    4725 runs
```

## Day 19
**commit 4394ed2**
```
Time (mean ± σ):      44.6 ms ±   2.4 ms    [User: 43.8 ms, System: 0.5 ms]
Range (min … max):    41.1 ms …  49.2 ms    71 runs
```
65% of my time is doing string equality

**commit a223fcf**: Find next cut in hashmap instead of looping over all towels
```
Time (mean ± σ):       6.9 ms ±   0.6 ms    [User: 6.1 ms, System: 0.5 ms]
Range (min … max):     6.0 ms …  10.4 ms    345 runs
```

## Day 20
**commit 8161060**
```
Time (mean ± σ):      40.3 ms ±   0.3 ms    [User: 39.6 ms, System: 0.5 ms]
Range (min … max):    40.0 ms …  41.4 ms    74 runs
```
**commit 91d5802**: don't search outside of the map
```
Time (mean ± σ):      24.3 ms ±   0.8 ms    [User: 23.3 ms, System: 0.8 ms]
Range (min … max):    15.7 ms …  25.4 ms    123 runs
```

## Day 21
**commit c67badd**
```
Time (mean ± σ):       1.0 ms ±   0.2 ms    [User: 0.2 ms, System: 0.5 ms]
Range (min … max):     0.4 ms …   1.5 ms    3353 runs
```

## Day 22
**commit bf71142**
```
Time (mean ± σ):      26.9 ms ±   0.2 ms    [User: 26.3 ms, System: 0.4 ms]
Range (min … max):    26.7 ms …  28.2 ms    111 runs
```

## Day 23
**commit 736d58d** very slow implementation
```
Time (mean ± σ):     17.180 s ±  0.074 s    [User: 17.183 s, System: 0.001 s]
Range (min … max):   17.047 s … 17.285 s    10 runs
```

## Day 24
**commit 4eb057a**: part1 only as part2 was manual
```
Time (mean ± σ):     708.2 µs ± 239.0 µs    [User: 427.1 µs, System: 168.5 µs]
Range (min … max):   327.9 µs … 2099.4 µs    5151 runs
```

## Day 25
**commit 27553e3**
```
Time (mean ± σ):     946.9 µs ± 349.7 µs    [User: 630.0 µs, System: 210.1 µs]
Range (min … max):   412.9 µs … 2735.7 µs    3638 runs
```