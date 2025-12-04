import sys

dirs = [1, -1, 1j, -1j, 1+1j, 1-1j, -1+1j, -1-1j]

def remove(grid):
    total = 0
    removed = set()
    for p in grid:
        count = sum(p + d in grid for d in dirs)
        if count < 4:
            total += 1
            removed.add(p)
    return removed


def solve(grid):
    total = 0
    while True:
        pos = remove(grid)
        if not pos: return total
        total += len(pos)
        grid -= pos


def parse(lines):
    grid = set()
    for r, line in enumerate(lines):
        for c, char in enumerate(line.strip()):
            if char == '@':
                grid.add(c + r*1j)
    return grid


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    print(solve(parse(lines)))

