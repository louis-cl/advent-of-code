import fileinput

numbers = list(map(int, fileinput.input()))

seen = set()

for n in numbers:
    want = 2020 - n
    if want in seen:
        print("Solution is", want*n)
    else:
        seen.add(n)