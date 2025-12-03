import sys

def solve(lines):
    total = 0
    for ints in lines:
        jolts = 0
        start = 0
        n = len(ints)
        for rem in range(12, 0, -1):
            best = max(range(start, n-rem+1), key=ints.__getitem__)
            jolts = jolts * 10 + ints[best]
            start = best + 1
        print(jolts)
        total += jolts
    return total


def parse(lines):
    for line in lines:
        yield list(map(int, line.strip()))


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    print(solve(parse(lines)))
