ZIG_BUILD=zig build
EXECUTABLE_DIR=./zig-out/bin

run:
	$(ZIG_BUILD) day$(day)

test:
	$(ZIG_BUILD) day$(day)_test

bench:
	$(ZIG_BUILD) day$(day)_install -Doptimize=ReleaseFast
	hyperfine --shell=none --warmup 3 '$(EXECUTABLE_DIR)/day$(day)'

prof:
	$(ZIG_BUILD) day$(day)_install -Doptimize=ReleaseSafe
	valgrind --tool=callgrind $(EXECUTABLE_DIR)/day$(day) --callgrind-out-file callgrind.out
	kcachegrind callgrind.out
	@rm -f callgrind.out

table:
	python3 table.py

run_%:
	$(MAKE) --no-print-directory run day=$*

run_all:
	$(ZIG_BUILD) all_install -Doptimize=ReleaseFast
	for i in $(shell seq 1 25); do \
		echo "\033[1m=== Running Day $$i ===\033[0m"; \
		./zig-out/bin/day$$i; \
	done

test_%:
	$(MAKE) --no-print-directory test day=$*

bench_%:
	$(MAKE) --no-print-directory bench day=$*

perf_all:
	$(ZIG_BUILD) all_install -Doptimize=ReleaseFast
	hyperfine -N --parameter-scan day 1 25 -D 1 './zig-out/bin/day{day}'

prof_%:
	$(MAKE) --no-print-directory prof day=$*

