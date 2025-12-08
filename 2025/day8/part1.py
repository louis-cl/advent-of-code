import sys
import heapq
from itertools import combinations
from collections import Counter
import math

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


def solve(boxes, times):
    dists = []
    for a, b in combinations(boxes, 2):
        dist = sum((p - q)**2 for p, q in zip(a, b))
        dists.append((dist, a, b))
    
    heapq.heapify(dists)

    indices = {b: i for i, b in enumerate(boxes)}
    uf = UnionFind(len(boxes))

    for _ in range(times):
        _, a, b = heapq.heappop(dists)
        idx_a, idx_b = indices[a], indices[b]
        uf.unite(idx_a, idx_b)

    top_3 = Counter(uf.find(i) for i in uf.parent).most_common(3)
    print(top_3)
    return math.prod(size for _, size in top_3)


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    
    boxes = set()
    for l in lines:
        if l.strip():
            p = tuple(map(int, l.split(',')))
            boxes.add(p)
    
    print(solve(boxes, 1000))