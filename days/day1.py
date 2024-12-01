#!/usr/bin/env python

def part1(data):
    data = [int(s) for s in data.split()]
    a,b = data[::2], data[1::2]
    ans = sum(abs(x-y) for x,y in zip(sorted(a), sorted(b)))
    return ans


def part2(data):
    data = [int(s) for s in data.split()]
    a,b = data[::2], data[1::2]
    ans = sum(x * b.count(x) for x in a)
    return ans


data = '''
3   4
4   3
2   5
1   3
3   9
3   3
'''
assert part1(data) == 11
assert part2(data) == 31


data = open('day1.in').read()
ans = part1(data)
print('part1:', ans)
ans = part2(data)
print('part2:', ans)
