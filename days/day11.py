#!/usr/bin/env python
from collections import defaultdict


def part1(data, N=25):
    stones = {int(s):1 for s in data.split()}

    for _ in range(N):
        state = defaultdict(int)
        for x,n in stones.items():
            if x == 0:
                state[1] += n
            else:
                s = str(x)
                t = len(s)
                if t % 2 == 0:
                    a,b = map(int, [s[:t//2], s[t//2:]])
                    state[a] += n
                    state[b] += n
                else:
                    state[x * 2024] += n
        stones = state
            
    ans = sum(stones.values())
    return ans


def part2(data):
    return part1(data, N=75)


data = '''
125 17
'''
assert part1(data) == 55312


data = open('day11.in').read()
ans = part1(data)
print('part1:', ans)
ans = part2(data)
print('part2:', ans)
