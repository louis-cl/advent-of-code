import sys

def solve(lines):
    dial = 50
    count = 0
    for line in lines:
        sign = 1 if line[0] == 'R' else -1
        mag = int(line[1:])
        dial += sign * mag
        dial %= 100
        if dial == 0:
            count += 1
    return count


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    lines = list(map(lambda x: x.strip(), lines))
    print(solve(lines))

