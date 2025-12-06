import sys
import math
from itertools import groupby

def solve(lines):
    ops = lines[-1].split()
    columns = ["".join(l).strip() for l in zip(*lines[:-1])]
    problems = [
        list(map(int, nums))
        for keep, nums in groupby(columns, key=bool) if keep
    ]
    
    total = 0
    for op, nums in zip(ops, problems):
        if op == '+':
            total += sum(nums)
        else:
            total += math.prod(nums)
    return total


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    print(solve(lines))

