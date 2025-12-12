import sys
import numpy as np

def variations(present):
    vars = set()
    for _ in range(4):
        present = np.rot90(present)
        vars.add(present.tobytes())
        vars.add(np.fliplr(present).tobytes())
        vars.add(np.flipud(present).tobytes())
    return [np.frombuffer(v, dtype=bool).reshape(present.shape) for v in vars]


def pprint(present):
    for row in present:
        print(''.join('#' if cell else '.' for cell in row))
    print()


def fits(presents, rows, cols, counts):
    # obviously wont fit
    area_needed = sum(p[0].sum() * counts[i] for i, p in enumerate(presents))
    if area_needed > rows * cols:
        return False
    return True # THIS IS GOOD ENOUGH: (╯°□°)╯︵ ┻━┻    
    
    # Original code left for posterity: always run the stupid solution first :)

    # # let's try a stupid backtracking
    # grid = np.zeros((rows, cols), dtype=bool)
    # # count[i] = number of presents[i] to fit in the grid, any variation
    # def backtrack(i):
    #     if i == len(presents):
    #         pprint(grid)
    #         return True
    #     if counts[i] == 0:
    #         return backtrack(i+1)
    #     # try to place each variation of present[i]
    #     for j, var in enumerate(presents[i]):
    #         pr, pc = var.shape
    #         for r in range(rows - pr + 1):
    #             for c in range(cols - pc + 1):
    #                 if np.logical_and(grid[r:r+pr, c:c+pc], var).sum() == 0:
    #                     # print(f"Placing present {i} variation {j} at {(r,c)}")
    #                     # place present
    #                     grid[r:r+pr, c:c+pc] |= var
    #                     counts[i] -= 1
    #                     if backtrack(i):
    #                         return True
    #                     # remove present
    #                     grid[r:r+pr, c:c+pc] &= ~var
    #                     counts[i] += 1
    #     return False
    
    # return backtrack(0)


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        blocks = f.read().split("\n\n")
    
    presents = []
    for i, block in enumerate(blocks):
        if "x" not in block: # present
            present = np.array([[c == '#' for c in line] for line in block.splitlines()[1:]])
            presents.append(variations(present))
            # print(f"Present {i} has {len(presents[-1])} variations")
            # for v in presents[-1]:
            #     pprint(v)
            #     print()
        else: # case
            total = 0
            for line in block.splitlines():
                dims, *nums = line.split()
                cols,rows = map(int, dims[:-1].split('x'))
                counts = list(map(int, nums))
                if fits(presents, rows, cols, counts):
                    total += 1
    
    print(total)

        