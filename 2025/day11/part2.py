import sys
from functools import cache

graph = {}

@cache
def paths(start, dac, fft):
    if start == 'out': return dac and fft
    dac |= start == 'dac'
    fft |= start == 'fft'
    return sum(paths(n, dac, fft) for n in graph[start])


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    
    for line in lines:
        left, right = map(str.strip, line.split(':'))
        graph[left] = set(right.split())
    
    print(paths('svr', False, False))