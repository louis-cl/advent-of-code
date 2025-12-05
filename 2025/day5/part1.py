import sys

def solve(rangeLines, idLines):
    ranges = []
    for line in rangeLines.splitlines():
        a,b = map(int, line.split('-'))
        ranges.append(range(a, b+1))

    fresh = 0
    for id in idLines.splitlines():
        if any(int(id) in r for r in ranges):
            fresh += 1
    return fresh

if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        blocks = f.read().rstrip().split('\n\n')
    print(solve(*blocks))

