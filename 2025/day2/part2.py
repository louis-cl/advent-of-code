import sys


def isInvalidPeriod(s, period):
    n = len(s)
    if n % period != 0: return False
    bit = s[:period]
    start = period
    while start+period <= n:
        if s[start:start+period] != bit:
            return False
        start += period
    return True


def isInvalid(id):
    for period in range(1, len(id)//2+1):
        # print("test invalid", id, period)
        if isInvalidPeriod(id, period):
            # print("invalid ", id, period)
            return True
    return False


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

