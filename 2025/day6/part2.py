import sys
import math


def solve(lines):
    ops = lines[-1].split()
    i = 0
    nums = []
    total = 0
    for l in zip(*lines[:-1]):
        val = "".join(l).strip()
        if val:
            nums.append(int(val))
        else: # space column
            if ops[i] == '+': 
                total += sum(nums)
            else:
                total += math.prod(nums)
            nums = []
            i += 1
    return total


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    print(solve(lines))

