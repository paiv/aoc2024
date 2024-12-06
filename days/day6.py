#!/usr/bin/env python


def part1(data):
    lines = data.strip().splitlines()
    grid = {(x+1j*y):c for y,row in enumerate(lines) for x,c in enumerate(row)}
    start = next(p for p,c in grid.items() if c == '^')

    seen = set()
    p, d = start, -1j
    while (c := grid.get(p + d)):
        if c == '#':
            d *= 1j
        else:
            p += d
            seen.add(p)

    ans = len(seen)
    return ans


def part2(data):
    lines = data.strip().splitlines()
    grid = {(x+1j*y):c for y,row in enumerate(lines) for x,c in enumerate(row)}
    start = next(p for p,c in grid.items() if c == '^')

    def scan():
        seen = set()
        p, d = start, -1j
        while (c := grid.get(p + d)):
            if c == '#':
                d *= 1j
            else:
                p += d
                if p not in seen:
                    yield p
                    seen.add(p)

    def oracle(patch):
        g = dict(grid)
        g[patch] = '#'
        seen = set()
        p, d = start, -1j
        while (c := g.get(p + d)):
            if c == '#':
                d *= 1j
            else:
                p += d
            k = (p, d)
            if k in seen:
                return True
            seen.add(k)
        return False

    ans = 0
    for p in scan():
        ans += oracle(p)
    return ans


data = '''
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
'''
assert part1(data) == 41
assert part2(data) == 6


data = open('day6.in').read()
ans = part1(data)
print('part1:', ans)
ans = part2(data)
print('part2:', ans)
