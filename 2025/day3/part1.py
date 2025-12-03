import sys

def solve(lines):
    jolts = 0
    for ints in lines:
        besti = 0
        best = ints[:2]
        n = len(ints)
        for i in range(1, n):
            if i+1 < n and ints[i] > best[0]:
                besti = i
                best = ints[i:i+2]
            elif i > besti and ints[i] > best[1]:
                best[1] = ints[i]

        jolts += best[0] * 10 + best[1]
    return jolts


def parse(lines):
    for line in lines:
        yield list(map(int, line.strip()))


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    print(solve(parse(lines)))

