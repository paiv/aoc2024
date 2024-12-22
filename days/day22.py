#!/usr/bin/env python
from collections import defaultdict


def part1(data, M=16777216, N=2000):
    nums = list(map(int, data.split()))

    def calc(x):
        for _ in range(N):
            x = (x ^ (x << 6)) % M
            x = (x ^ (x >> 5)) % M
            x = (x ^ (x * 2048)) % M
        return x

    ans = sum(map(calc, nums))
    return ans


def part2(data, M=16777216, N=2000):
    nums = list(map(int, data.split()))

    def calc(x):
        s = x % 10
        for _ in range(N):
            x = (x ^ (x << 6)) % M
            x = (x ^ (x >> 5)) % M
            x = (x ^ (x * 2048)) % M
            k = (x % 10)
            yield (k, k - s)
            s = k

    seq = [list(zip(*p)) for p in map(calc, nums)]

    cache = defaultdict(int)
    for ps, ks in seq:
        seen = set()
        for i in range(len(ks)-3):
            k = ks[i:i+4]
            if k not in seen:
                seen.add(k)
                cache[k] += ps[i+3]

    ans = max(cache.values())
    return ans


data = '''
1
10
100
2024
'''
assert part1(data) == 37327623

data = '''
1
2
3
2024
'''
assert part2(data) == 23


data = open('day22.in').read()
ans = part1(data)
print('part1:', ans)
ans = part2(data)
print('part2:', ans)
