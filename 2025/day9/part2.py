import sys
from itertools import combinations

def is_in(p, edges):
    x,y = p
    # exactly on edge
    for (px,py),(qx,qy) in edges:
        if px == qx == x and min(py,qy) <= y <= max(py,qy):
            return True
        if py == qy == y and min(px,qx) <= x <= max(px,qx):
            return True
    # ray casting to the right
    inside = False
    for (px,py),(qx,qy) in edges:
        # vertical edge on the right
        if px == qx > x and (py > y) != (qy > y):
            inside = not inside
    return inside


def overlaps(l1, r1, l2, r2):
    return max(l1, l2) < min(r1, r2)


def edge_crosses(a, b, edges):
    minx, maxx = sorted([a[0], b[0]])
    miny, maxy = sorted([a[1], b[1]])

    for (px,py),(qx,qy) in edges:
        if px == qx: # vertical edge
            # x inside the rectangle and y crossing
            if minx < px < maxx and overlaps(miny, maxy, min(py,qy), max(py,qy)):
                return True
        elif miny < py < maxy and overlaps(minx, maxx, min(px,qx), max(px,qx)):
                return True
    return False


def is_valid(a, b, edges):
    c = (a[0], b[1])
    d = (b[0], a[1])
    # all corners inside, we know a,b are already
    if not is_in(c, edges) or not is_in(d, edges):
        return False
    # no side should cross an edge of the polygon
    if edge_crosses(a, b, edges):
        return False
    return True


def solve(tiles):
    edges = list(zip(tiles, tiles[1:]+tiles[:1]))
    max_area = 0
    for a,b in combinations(tiles, 2):
        s1 = abs(a[0]-b[0])+1
        s2 = abs(a[1]-b[1])+1
        area = s1 * s2
        if area > max_area and is_valid(a, b, edges):
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