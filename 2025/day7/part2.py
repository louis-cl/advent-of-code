import sys
from collections import defaultdict


def solve(grid, start):
    total_beams = 1
    beams = defaultdict(int)  # pos -> #beams reaching pos
    beams[start] = 1
    while beams:
        new_beams = defaultdict(int)
        for pos, count in beams.items():
            pos = pos + 1j
            if pos not in grid:
                continue
            if grid[pos] == '.':
                new_beams[pos] += count # love defaultdict for the 0
            else:  # ^, we trust we don't go out of bounds
                total_beams += count  # duplicate current count
                new_beams[pos - 1] += count
                new_beams[pos + 1] += count
        beams = new_beams
    return total_beams

if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    grid = {}
    start = None
    for r, line in enumerate(lines):
        for c, char in enumerate(line):
            if char == 'S':
                start = c + r*1j
            else:
                grid[c + r*1j] = char
    print(solve(grid, start))

