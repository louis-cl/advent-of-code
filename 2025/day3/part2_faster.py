import sys

def solve(lines):
    total = 0
    for ints in lines:
        discards = len(ints) - 12
        seq = []
        for x in ints:
            while discards > 0 and seq and seq[-1] < x:
               seq.pop()
               discards -= 1
            if len(seq) < 12:
                seq.append(x)
        total += int("".join(map(str, seq[:12])))
    return total


def parse(lines):
    for line in lines:
        yield list(map(int, line.strip()))


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
    print(solve(parse(lines)))
