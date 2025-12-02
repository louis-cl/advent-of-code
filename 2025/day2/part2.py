import sys


def is_periodic(s, period):
    multiplier, rem = divmod(len(s), period)
    if rem != 0: return False
    return s == s[:period] * multiplier


def is_invalid(s):
    for period in range(1, len(s) // 2 + 1):
        if is_periodic(s, period):
            return True
    return False


def invalids(low, high):
    for x in range(low, high + 1):
        if is_invalid(str(x)): yield x


def solve(line):
    total = 0
    for part in line.split(','):
        low, high = map(int, part.split('-'))
        total += sum(invalids(low, high))
    return total


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        line = f.read().strip()
    print(solve(line))