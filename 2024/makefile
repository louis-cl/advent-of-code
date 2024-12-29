ZIG_BUILD=zig build
OPTIMIZE_FLAG=-Doptimize=ReleaseFast
EXECUTABLE_DIR=./zig-out/bin

run:
	$(ZIG_BUILD) day$(day)

test:
	$(ZIG_BUILD) day$(day)_test

perf:
	$(ZIG_BUILD) day$(day)_install -Doptimize=ReleaseFast
	hyperfine --shell=none --warmup 3 '$(EXECUTABLE_DIR)/day$(day)'

prof:
	$(ZIG_BUILD) day$(day)_install -Doptimize=ReleaseSafe
	valgrind --tool=callgrind $(EXECUTABLE_DIR)/day$(day)

run_%:
	$(MAKE) --no-print-directory run day=$*

test_%:
	$(MAKE) --no-print-directory test day=$*

bench_%:
	$(MAKE) --no-print-directory perf day=$*

prof_all:
	$(ZIG_BUILD) all_install -Doptimize=ReleaseFast
	hyperfine -N --parameter-scan day 1 25 -D 1 './zig-out/bin/day{day}'

prof_%:
	$(MAKE) --no-print-directory prof day=$*

