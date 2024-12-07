#!/usr/bin/env python
import itertools


def joini(x, y):
    i = y
    while i:
        i //= 10
        x *= 10
    return x + y


ops = [
    int.__add__,
    int.__mul__,
    joini,
]


def valid(xs, t, ops=ops):
    fs = [ops] * (len(xs)-1)
    for ps in itertools.product(*fs):
        x = xs[0]
        for f,y in zip(ps, xs[1:]):
            x = f(x, y)
        if x == t:
            return True


def valid(xs, t, ops=ops):
    rs = [xs[0]]
    for y in xs[1:]:
        rs = [f(x,y) for x in rs for f in ops]
    return t in rs


def part1(data, ops=ops[:2]):
    ans = 0
    for line in data.strip().splitlines():
        n,ns = line.split(':')
        t, *xs = map(int, (n + ns).split())
        if valid(xs, t, ops):
            ans += t
    return ans


def part2(data):
    return part1(data, ops)


data = '''
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
'''
assert part1(data) == 3749
assert part2(data) == 11387


data = open('day7.in').read()
ans = part1(data)
print('part1:', ans)
ans = part2(data)
print('part2:', ans)
