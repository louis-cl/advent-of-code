import sys
import heapq
from itertools import combinations
from collections import Counter

class UnionFind:
    def __init__(self, size):
        self.parent = list(range(size))
    
    def find(self, i):
        if self.parent[i] != i:
            self.parent[i] = self.find(self.parent[i])
        return self.parent[i]
    
    def unite(self, i, j):
        irep = self.find(i)
        jrep = self.find(j)
        if irep != jrep:
            self.parent[irep] = jrep
            return True
        return False
    

    def is_single_unit(self):
        root = self.find(0)
        for i in range(1, len(self.parent)):
            if self.find(i) != root:
                return False
        return True


def solve(boxes):
    dists = []
    for a, b in combinations(boxes, 2):
        dist = sum((p - q)**2 for p, q in zip(a, b))
        dists.append((dist, a, b))
    
    heapq.heapify(dists)

    indices = {b: i for i, b in enumerate(boxes)}
    uf = UnionFind(len(boxes))

    last_connection = None
    while not uf.is_single_unit():
        _, a, b = heapq.heappop(dists)
        idx_a, idx_b = indices[a], indices[b]
        if uf.unite(idx_a, idx_b):
            last_connection = a[0] * b[0]

    return last_connection

if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    
    points = set()
    for l in lines:
        if l.strip():
            p = tuple(map(int, l.split(',')))
            points.add(p)
    
    print(solve(points))