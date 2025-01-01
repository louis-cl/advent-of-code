ZIG_BUILD=zig build
EXECUTABLE_DIR=./zig-out/bin

run:
	$(ZIG_BUILD) day$(day)

test:
	$(ZIG_BUILD) day$(day)_test

perf:
	$(ZIG_BUILD) day$(day)_install -Doptimize=ReleaseFast
	hyperfine --shell=none --warmup 3 '$(EXECUTABLE_DIR)/day$(day)'

prof:
	$(ZIG_BUILD) day$(day)_install -Doptimize=ReleaseFast
	valgrind --tool=callgrind $(EXECUTABLE_DIR)/day$(day) --callgrind-out-file callgrind.out
	kcachegrind callgrind.out
	@rm -f callgrind.out

table:
	python3 table.py

run_%:
	$(MAKE) --no-print-directory run day=$*

test_%:
	$(MAKE) --no-print-directory test day=$*

bench_%:
	$(MAKE) --no-print-directory perf day=$*

perf_all:
	$(ZIG_BUILD) all_install -Doptimize=ReleaseFast
	hyperfine -N --parameter-scan day 1 25 -D 1 './zig-out/bin/day{day}'

prof_%:
	$(MAKE) --no-print-directory prof day=$*

