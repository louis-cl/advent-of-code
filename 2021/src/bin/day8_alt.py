import itertools

inputs = list(open('../../input/day8').read().splitlines())
# inputs = ["dfbgeca cfbega aedcfb faebgd feabd aeg gbde eg cdgaf dafge | bfeacg gaefd ega bcafge"]
# inputs = [
# "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe",
# "edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc",
# "fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg",
# "fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb",
# "aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea",
# "fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb",
# "dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe",
# "bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef",
# "egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb",
# "gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce"
# ]

nums = {
    "abcefg": 0,
    "cf": 1,
    "acdeg": 2,
    "acdfg": 3,
    "bcdf": 4,
    "abdfg": 5,
    "abdefg": 6,
    "acf": 7,
    "abcdefg": 8,
    "abcdfg": 9
}

def repr(its):
    return sorted("".join(sorted(s)) for s in its)

nums_repr = repr(nums.keys())

def decode(sample, perm):
    return ("".join(map(lambda c: perm[c], s)) for s in sample)

def solve(case):
    sample, output = (x.split() for x in case.split(' | '))
    perm = None
    for p_values in itertools.permutations("abcdefg"):
        perm = dict(zip("abcdefg", p_values))
        sample_p = decode(sample, perm)
        if repr(sample_p) == nums_repr:
            break

    return "".join(str(nums["".join(sorted(s))]) for s in decode(output, perm))


print(sum(int(solve(case)) for case in inputs))
