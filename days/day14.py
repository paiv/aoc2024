#!/usr/bin/env python
import io
import itertools
import re
from collections import Counter


def part1(data, N=100, w=101, h=103):
    data = list(map(int, re.findall(r'\-?\d+', data)))
    px = data[0::4]
    py = data[1::4]
    vx = data[2::4]
    vy = data[3::4]

    grid = Counter()
    for i in range(len(px)):
        x = (px[i] + vx[i] * N) % w
        y = (py[i] + vy[i] * N) % h
        grid[x,y] += 1

    w2 = w // 2
    h2 = h // 2
    qs = Counter()

    for (x,y), n in grid.items():
        if x == w2 or y == h2:
            continue
        qs[x // (w2+1), y // (h2+1)] += n

    ans = 1
    for n in qs.values():
        ans *= n
    return ans


def part2(data, w=101, h=103):
    data = list(map(int, re.findall(r'\-?\d+', data)))
    px = data[0::4]
    py = data[1::4]
    vx = data[2::4]
    vy = data[3::4]

    for t in itertools.count(1):
        grid = Counter()
        for i in range(len(px)):
            x = (px[i] + vx[i] * t) % w
            y = (py[i] + vy[i] * t) % h
            grid[x,y] += 1

        if all(n == 1 for n in grid.values()):
            for ox,oy in grid:
                if all(grid.get((ox+i, oy)) for i in range(20)):
                    return t


def display(grid, w, h):
    with io.StringIO() as so:
        for y in range(h):
            for x in range(w):
                c = grid.get((x,y), '.')
                print(c, end='', file=so)
            print(file=so)
        print(so.getvalue())


data = '''
p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3
'''
assert part1(data, w=11, h=7) == 12


data = open('day14.in').read()
ans = part1(data)
print('part1:', ans)
ans = part2(data)
print('part2:', ans)
