import sys
from itertools import combinations

def solve(tiles):
    max_area = 0
    for a,b in combinations(tiles, 2):
        s1 = abs(a[0]-b[0])+1
        s2 = abs(a[1]-b[1])+1
        area = s1 * s2
        if area > max_area:
            max_area = area
    return max_area


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    
    tiles = []
    for l in lines:
        if l.strip():
            p = tuple(map(int, l.split(',')))
            tiles.append(p)
    
    print(solve(tiles))