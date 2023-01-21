import fileinput

numbers = list(map(int, fileinput.input()))

seen = set(numbers)

for i in numbers:
    for j in numbers:
            if 2020-i-j in seen:
                print('Sol', i*j*(2020-i-j))
