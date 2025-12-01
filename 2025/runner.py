#!/usr/bin/env python3
"""Runner for AoC 2025 solutions and visualizations."""
import argparse
import re
import subprocess
import sys
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(
        description="Run AoC 2025 solutions",
        usage="%(prog)s dayN/input.txt [--part N] [--viz] [--export]"
    )
    parser.add_argument("input_file", help="Path to input file (e.g., day1/input.txt, day1/sample.txt)")
    parser.add_argument("--part", "-p", type=int, choices=[1, 2], help="Run only part 1 or 2")
    parser.add_argument("--viz", "-v", action="store_true", help="Run visualization")
    parser.add_argument("--export", "-e", action="store_true", help="Export visualization to mp4")
    args = parser.parse_args()

    input_path = Path(args.input_file)
    if not input_path.exists():
        print(f"Input file {input_path} not found")
        sys.exit(1)

    # Infer day from path (e.g., day1/input.txt -> day 1)
    day_match = re.search(r'day(\d+)', str(input_path))
    if not day_match:
        print(f"Could not infer day number from path: {input_path}")
        print("Expected path format: dayN/input.txt")
        sys.exit(1)

    day_num = int(day_match.group(1))
    day_dir = Path(__file__).parent / f"day{day_num}"

    if not day_dir.exists():
        print(f"Day {day_num} not found. Create it with: cp -r template day{day_num}")
        sys.exit(1)

    if args.viz or args.export:
        viz_file = day_dir / "viz.py"
        if not viz_file.exists():
            print(f"No viz.py found in {day_dir}")
            sys.exit(1)
        cmd = [sys.executable, str(viz_file), str(input_path.absolute())]
        if args.export:
            cmd.append("--export")
        subprocess.run(cmd)
    else:
        parts = [args.part] if args.part else [1, 2]
        for p in parts:
            part_file = day_dir / f"part{p}.py"
            if part_file.exists():
                print(f"=== Day {day_num} Part {p} ===")
                subprocess.run([sys.executable, str(part_file), str(input_path.absolute())])
            elif args.part:
                print(f"part{p}.py not found in {day_dir}")
                sys.exit(1)


if __name__ == "__main__":
    main()
