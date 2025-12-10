import sys
from dataclasses import dataclass
import re
from collections import deque
import numpy as np

@dataclass
class Machine:
    objective: int # target as bitmask
    buttons: list # list of button masks


def ints(s):
    return list(map(int, re.findall(r'\d+', s)))


# [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
def parse(line):
    parts = line.strip().split(' ')
    
    obj = 0
    for i, c in enumerate(parts[0][1:-1]):
        if c == '#':
            obj |= (1 << i)
            
    buttons = []
    for b in parts[1:-1]:
        mask = 0
        for idx in ints(b):
            mask |= (1 << idx)
        buttons.append(mask)

    return Machine(objective=obj, buttons=buttons)


def solve(machine):
    queue = deque([(0, 0)])
    visited = {0}
    
    while queue:
        current, cost = queue.popleft()
        if current == machine.objective:
            return cost
        
        for button in machine.buttons:
            next = current ^ button
            if next not in visited:
                visited.add(next)
                queue.append((next, cost + 1))
    
    raise RuntimeError("We got problems")


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    
    machines = [parse(line) for line in lines]
    sol = sum(map(solve, machines))
    print(sol)