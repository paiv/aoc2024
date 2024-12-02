#!/usr/bin/env python

def part1(data):

    def valid(d):
        t = all((x-y in (1,2,3)) for x,y in zip(d, d[1:]))
        q = all((y-x in (1,2,3)) for x,y in zip(d, d[1:]))
        return t or q

    data = [[int(x) for x in s.split()] for s in data.strip().splitlines()]
    ans = sum(valid(x) for x in data)
    return ans


def part2(data):

    def valid0(d):
        t = all((x-y in (1,2,3)) for x,y in zip(d, d[1:]))
        q = all((y-x in (1,2,3)) for x,y in zip(d, d[1:]))
        return t or q

    def valid(d):
        if valid0(d): return True
        for i in range(len(d)):
            t = d[:i] + d[i+1:]
            if valid0(t): return True
        return False

    data = [[int(x) for x in s.split()] for s in data.strip().splitlines()]
    ans = sum(valid(x) for x in data)
    return ans


data = '''
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
'''
assert part1(data) == 2
assert part2(data) == 4


data = open('day2.in').read()
ans = part1(data)
print('part1:', ans)
ans = part2(data)
print('part2:', ans)
