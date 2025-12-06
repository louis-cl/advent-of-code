import sys
import math

def solve(lines):
    grid = (line.strip().split() for line in lines)
    total = 0
    for col in zip(*grid):
        *numbers, op = col
        if op == '+':
            total += sum(int(n) for n in numbers)
        else:
            total += math.prod(int(n) for n in numbers)
    return total

if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    print(solve(lines))

