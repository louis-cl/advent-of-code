import sys

def solve(grid, start):
    splits = 0
    beams = {start}
    while beams:
        new_beams = set()
        for pos in beams:
            pos = pos + 1j
            # print("beam at", beam, "going to", pos)
            if pos not in grid: continue
            if grid[pos] == '.':
                new_beams.add(pos)
            else: # ^
                splits += 1
                new_beams.add(pos+1)
                new_beams.add(pos-1)
        beams = new_beams
    return splits

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

