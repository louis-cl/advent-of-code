import sys
from dataclasses import dataclass
import re
import numpy as np
from scipy.optimize import milp, Bounds, LinearConstraint


@dataclass
class Machine:
    # objective[i] = target jolts for counter i
    objective: np.ndarray # N
    # buttons[i][j] = 1 if counter i is increased by button j
    buttons: np.ndarray # NxM


def ints(s):
    return list(map(int, re.findall(r'\d+', s)))


# [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
def parse(line):
    parts = line.strip().split(' ')
    
    obj = np.array(ints(parts[-1].strip()[1:-1]))
    buttons = np.zeros((len(obj), len(parts)-2), dtype=int)    
    for j, b in enumerate(parts[1:-1]):
        for i in ints(b):
            buttons[i][j] = 1
    
    return Machine(objective=obj, buttons=buttons)


def solve(machine):
    # min(sum(x)) where M * x = t where x >= 0
    M = machine.buttons.shape[1]
    result = milp(
        c=np.ones(M), # same weight for each button
        constraints=LinearConstraint(machine.buttons, machine.objective, machine.objective), 
        bounds=Bounds(0, np.inf), 
        integrality=np.ones(M) # all integers
    )

    if not result.success:
        raise RuntimeError("We got problems")
    return int(result.fun)


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    
    machines = [parse(line) for line in lines if line.strip()]
    sol = sum(map(solve, machines))
    print(sol)