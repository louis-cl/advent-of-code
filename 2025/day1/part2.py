import sys

def solve(data):
    dial = 50
    count = 0
    for line in lines:
        sign = 1 if line[0] == 'R' else -1
        mag = int(line[1:])
        # pre: dial is [0,99]
        q, new_dial = divmod(dial + sign * mag, 100)
        print(f"from {dial} to {new_dial}: {abs(q)}")
        
        count += abs(q) # loops
        # need to add landing on 0 exactly going left
        # because 5+95 / 100 = 1 but 5-5 / 100 = 0
        if sign == -1 and new_dial == 0:
            count += 1
        # but remove 0-5 / 100 = -1 since we didn't cross
        if sign == -1 and dial == 0:
            count -= 1

        dial = new_dial

    return count


if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()

    lines = list(map(lambda x: x.strip(), lines))
    print(solve(lines))

