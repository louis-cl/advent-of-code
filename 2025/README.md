# Advent of Code 2025

## Setup

```bash
uv sync
source .venv/bin/activate
```

## Usage

```bash
# Run solutions (runner infers day from path)
python runner.py day1/input.txt            # Run day 1 part1 and part2
python runner.py day1/input.txt -p 1       # Run only part1
python runner.py day1/sample.txt           # Use sample input
python day1/part1.py day1/input.txt        # Run directly (requires input file path)

# Visualization (interactive controls: R=record, Q=quit, UP/DOWN=speed)
python day1/viz.py day1/input.txt          # Run viz with input file
python runner.py day1/input.txt --viz      # Same via runner
python runner.py day1/input.txt --export   # Export to viz.mp4
