import sys

def solve(rangeLines, _):
    ranges = []
    for line in rangeLines.splitlines():
        a,b = map(int, line.split('-'))
        ranges.append([a, b])
    
    ranges.sort()

    total = 0
    a,b = ranges[0]
    for c,d in ranges[1:]:
        if c <= b + 1: # overlap
            b = max(b, d) # biggest end wins
        else: # gap
            total += b - a + 1 # count previous range
            a,b = c,d # start new range
    
    return total + b - a + 1 # final range

if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        blocks = f.read().rstrip().split('\n\n')
    print(solve(*blocks))

