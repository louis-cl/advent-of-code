ZIG_BUILD=zig build
OPTIMIZE_FLAG=-Doptimize=ReleaseFast
EXECUTABLE=./zig-out/bin/aoc.zig

setup:
	$(ZIG_BUILD) -Dday=$(day) setup

run:
	$(ZIG_BUILD) -Dday=$(day) run

test:
	$(ZIG_BUILD) -Dday=$(day) test

perf:
	$(ZIG_BUILD) -Dday=$(day) $(OPTIMIZE_FLAG)
	hyperfine --shell=none --warmup 3 '$(EXECUTABLE)'

callgrind:
	$(ZIG_BUILD) -Dday=$(day) -Doptimize=ReleaseSafe
	valgrind --tool=callgrind $(EXECUTABLE)

setup_%:
	$(MAKE) --no-print-directory setup day=$*

run_%:
	$(MAKE) --no-print-directory run day=$*

test_%:
	$(MAKE) --no-print-directory test day=$*

perf_%:
	$(MAKE) --no-print-directory perf day=$*

callgrind_%:
	$(MAKE) --no-print-directory callgrind day=$*