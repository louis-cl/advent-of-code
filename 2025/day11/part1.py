import sys

def paths(graph, start):
    if start == 'out': return 1
    return sum(paths(graph, n) for n in graph[start])


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    
    graph = {}
    for line in lines:
        left, right = map(str.strip, line.split(':'))
        graph[left] = set(right.split())
    
    print(paths(graph, 'you'))