import subprocess
import re
import os
import json

testing = False
benchmark_file = ".benchmark_results.json"

# Load existing results
if os.path.exists(benchmark_file):
    with open(benchmark_file, "r") as f:
        stored_results = json.load(f)
else:
    stored_results = {}

print("Compiling all problems")
subprocess.run(["zig", "build", "all_install", "-Doptimize=ReleaseFast"], text=True)

executable_dir = "./zig-out/bin"
executables = [f"day{day}" for day in range(1, 26)]
results = []

def time_to_microseconds(time_str):
    return float(re.sub(r"[^\d.]", "", time_str)) * (1000 if "ms" in time_str else 1)

def format_time_from_microseconds(us_value):
    return f"{us_value / 1000:.1f} ms" if us_value >= 1000 else f"{us_value:.1f} µs"

def create_colored_table(rows, styles):
    headers = ["exe", "mean", "± σ"]
    col_widths = [max(len(str(item)) for item in col) for col in zip(headers, *rows)]
    aligned_rows = [
        [
            f"{style}{cell.ljust(width)}\033[0m"
            for cell, width, style in zip(row, col_widths, [style] * len(headers))
        ]
        for row, style in zip(rows, styles)
    ]
    header = " | ".join(header.ljust(width) for header, width in zip(headers, col_widths))
    separator = "-+-".join("-" * width for width in col_widths)
    data_rows = "\n".join(" | ".join(row) for row in aligned_rows)
    return f"{header}\n{separator}\n{data_rows}"

print("Running benchmarks")
if testing:
    results = [
        ("day1", "810.3 µs", "362.5 µs", 810.3, 362.5),
        ("day2", "787.6 µs", "287.7 µs", 787.6, 287.7),
        ("day3", "599.5 µs", "260.0 µs", 599.5, 260.0),
        ("day4", "737.7 µs", "325.7 µs", 737.7, 325.7),
        ("day5", "848.8 µs", "282.1 µs", 848.8, 282.1),
        ("day6", "21.9 ms", "0.2 ms", 21900, 200),
        ("day7", "1.0 ms", "0.5 ms", 1000, 500),
        ("day8", "601.0 µs", "295.2 µs", 601.0, 295.2),
        ("day9", "1.3 ms", "0.5 ms", 1300, 500),
        ("day10", "1.0 ms", "0.5 ms", 1000, 500),
        ("day11", "12.5 ms", "1.0 ms", 12500, 1000),
        ("day12", "1.7 ms", "0.5 ms", 1700, 500),
        ("day13", "672.1 µs", "270.8 µs", 672.1, 270.8),
        ("day14", "31.1 ms", "0.3 ms", 31100, 300),
        ("day15", "1.6 ms", "0.6 ms", 1600, 600),
        ("day16", "4.9 ms", "1.6 ms", 4900, 1600),
        ("day17", "585.4 µs", "285.2 µs", 585.4, 285.2),
        ("day18", "1.1 ms", "0.5 ms", 1100, 500),
        ("day19", "3.6 ms", "0.9 ms", 3600, 900),
        ("day20", "23.9 ms", "0.2 ms", 23900, 200),
        ("day21", "746.3 µs", "263.3 µs", 746.3, 263.3),
        ("day22", "26.7 ms", "0.2 ms", 26700, 200),
        ("day23", "2.3 ms", "0.7 ms", 2300, 700),
        ("day24", "936.9 µs", "467.0 µs", 936.9, 467.0),
        ("day25", "1.0 ms", "0.5 ms", 1000, 500),
    ]
else:
    for exe in executables:
        exe_path = f"{executable_dir}/{exe}"
        current_mtime = os.path.getmtime(exe_path)
        if exe in stored_results and stored_results[exe]["mtime"] == current_mtime:
            # Use stored results
            stored = stored_results[exe]
            print(f"{exe} cached {stored['mean']} ± {stored['std']}")
            results.append((exe, stored["mean"], stored["std"], stored["mean_value"], stored["std_value"]))
        else:
            # Run benchmark and store results
            try:
                output = subprocess.run(
                    ["hyperfine", "--shell=none", "--warmup", "3", exe_path],
                    text=True, capture_output=True
                )
                match = re.search(r"Time \(mean ± σ\):\s+([\d\.]+\s+\w+s)\s+±\s+([\d\.]+\s+\w+s)", output.stdout)
                if match:
                    mean, std = match.groups()
                    mean_value, std_value = time_to_microseconds(mean), time_to_microseconds(std)
                    print(f"{exe} measured {mean} ± {std}")
                    results.append((exe, mean, std, mean_value, std_value))
                    stored_results[exe] = {
                        "mtime": current_mtime,
                        "mean": mean,
                        "std": std,
                        "mean_value": mean_value,
                        "std_value": std_value,
                    }
                else:
                    raise ValueError("Error parsing output")
            except Exception as e:
                results.append((exe, "Error", "Error", float("inf"), float("inf")))
                stored_results[exe] = {
                    "mtime": current_mtime,
                    "mean": "Error",
                    "std": "Error",
                    "mean_value": float("inf"),
                    "std_value": float("inf"),
                }
    with open(benchmark_file, "w") as f:
        json.dump(stored_results, f, indent=4)

total_mean = sum(row[3] for row in results)
total_std = sum(row[4] for row in results)
results.append(("Total", format_time_from_microseconds(total_mean), format_time_from_microseconds(total_std), total_mean, total_std))

display_results = [(row[0], row[1], row[2]) for row in results]
styles = [
    "\033[1m" if row[0] == "Total" else (
        "\033[32m" if row[3] <= 1/25 * total_mean else  # green
        "\033[33m" if row[3] <= 4/25 * total_mean else # yellow
        "\033[31m" # red
    )
    for row in results
]

print(create_colored_table(display_results, styles))
