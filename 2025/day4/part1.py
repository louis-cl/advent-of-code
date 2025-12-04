import sys

dirs = [1, -1, 1j, -1j, 1+1j, 1-1j, -1+1j, -1-1j]

def solve(grid):
    total = 0
    for p in grid:
        np = (p + d for d in dirs)
        count = sum(1 for q in np if q in grid)
        if count < 4:
            total += 1
    return total


def parse(lines):
    grid = {}
    for r, line in enumerate(lines):
        for c, char in enumerate(line.strip()):
            if char == '@':
                grid[c + r*1j] = True
    return grid


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    print(solve(parse(lines)))

