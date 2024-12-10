#!/usr/bin/env python
from collections import deque


def part1(data):
    lines = data.strip().splitlines()
    grid = {(y,x):int(c) for y,s in enumerate(lines)
        for x,c in enumerate(s)}
    starts = [p for p,c in grid.items() if c == 0]
    neib = [(0,1), (0,-1), (1,0), (-1,0)]

    ans = 0
    for s in starts:
        fringe = deque([s])
        seen = {s}
        while fringe:
            pos = fringe.popleft()
            if grid[pos] == 9:
                ans += 1
                continue
            y,x = pos
            for dy,dx in neib:
                q = (y+dy, x+dx)
                if (h := grid.get(q)) is not None:
                    if h - grid[pos] == 1:
                        if q not in seen:
                            seen.add(q)
                            fringe.append(q)
    return ans


def part2(data):
    lines = data.strip().splitlines()
    grid = {(y,x):int(c) for y,s in enumerate(lines)
        for x,c in enumerate(s)}
    starts = [p for p,c in grid.items() if c == 0]
    neib = [(0,1), (0,-1), (1,0), (-1,0)]

    ans = 0
    for s in starts:
        fringe = deque([(s, tuple())])
        while fringe:
            pos, path = fringe.popleft()
            if grid[pos] == 9:
                ans += 1
                continue
            y,x = pos
            for dy,dx in neib:
                q = (y+dy, x+dx)
                if (h := grid.get(q)) is not None:
                    if h - grid[pos] == 1:
                        if q not in path:
                            fringe.append((q, path+(q,)))
    return ans



data = '''
0123
1234
8765
9876
'''
assert part1(data) == 1

data = '''
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
'''
assert part1(data) == 36
assert part2(data) == 81


data = open('day10.in').read()
ans = part1(data)
print('part1:', ans)
ans = part2(data)
print('part2:', ans)
