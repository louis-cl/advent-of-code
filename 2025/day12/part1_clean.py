import sys

if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        blocks = f.read().split("\n\n")
    
    presents = []
    for i, block in enumerate(blocks):
        if "x" not in block: # present
            presents.append(block.count('#'))
        else: # case
            total = 0
            for line in block.splitlines():
                dims, *nums = line.split()
                cols,rows = map(int, dims[:-1].split('x'))
                counts = list(map(int, nums))
                area_needed = sum(p * c for p, c in zip(presents, counts))
                if area_needed <= rows * cols:
                    total += 1
    
    print(total)

        