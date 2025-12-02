import sys


def isInvalid(id):
    n = len(id)
    if n % 2 != 0: return False
    # print("invalid", id[:n//2], id[n//2:])
    return id[:n//2] == id[n//2:]


def sumInvalid(low, high):
    sum = 0
    for x in range(low, high+1):
        if isInvalid(str(x)): sum += x
    return sum


def solve(line):
    total = 0
    for range in line.split(','):
        left, right = range.split('-')
        total += sumInvalid(int(left), int(right))
    return total


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    lines = list(map(lambda x: x.strip(), lines))
    print(solve(lines[0]))

