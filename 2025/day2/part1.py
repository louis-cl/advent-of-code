import sys


def is_invalid(s):
    mid, rem = divmod(len(s), 2)
    if rem != 0: return False
    # print("invalid", id[:n//2], id[n//2:])
    return s[:mid] == s[mid:]


def invalids(low, high):
    for x in range(low, high+1):
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

