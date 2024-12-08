#!/usr/bin/env python


def part1(data):
    lines = data.strip().splitlines()
    grid = {(x,y):c for y,s in enumerate(lines)
        for x,c in enumerate(s) if c != '.'}
    names = set(grid.values())
    w, h = len(lines[0]), len(lines)

    def gen(a, b):
        ax, ay = a
        bx, by = b
        x, y = (2 * ax - bx, 2 * ay - by)
        if (0 <= x < w) and (0 <= y < h):
            yield (x, y)
        x, y = (2 * bx - ax, 2 * by - ay)
        if (0 <= x < w) and (0 <= y < h):
            yield (x, y)

    pois = set()
    for n in names:
        ps = [p for p,c in grid.items() if c == n]
        for i, a in enumerate(ps):
            for b in ps[i+1:]:
                for p in gen(a, b):
                    pois.add(p)

    ans = len(pois)
    return ans


def part2(data):
    lines = data.strip().splitlines()
    grid = {(x,y):c for y,s in enumerate(lines)
        for x,c in enumerate(s) if c != '.'}
    names = set(grid.values())
    w, h = len(lines[0]), len(lines)

    def gen(a, b):
        ax, ay = a
        bx, by = b
        dx,dy = bx-ax, by-ay
        x,y = ax+dx, ay+dy
        while (0 <= x < w) and (0 <= y < h):
            yield (x, y)
            x += dx
            y += dy
        x,y = bx-dx, by-dy
        while (0 <= x < w) and (0 <= y < h):
            yield (x, y)
            x -= dx
            y -= dy

    pois = set()
    for n in names:
        ps = [p for p,c in grid.items() if c == n]
        for i, a in enumerate(ps):
            for b in ps[i+1:]:
                for p in gen(a, b):
                    pois.add(p)

    ans = len(pois)
    return ans


def display(grid, pois):
    import io
    coff = '\033[0m'
    con = '\033[37;41m'
    minx = min(x for x,y in grid)
    maxx = max(x for x,y in grid)
    miny = min(y for x,y in grid)
    maxy = max(y for x,y in grid)
    with io.StringIO() as so:
        for y in range(miny, maxy+1):
            for x in range(minx, maxx+1):
                c = grid.get((x,y), '.')
                if (x,y) in pois:
                    print(con, end='', file=so)
                    print(c, end='', file=so)
                    print(coff, end='', file=so)
                else:
                    print(c, end='', file=so)
            print(file=so)
        print(so.getvalue())


data = '''
..........
..........
..........
....a.....
..........
.....a....
..........
..........
..........
..........
'''
assert part1(data) == 2


data = '''
..........
..........
..........
....a.....
........a.
.....a....
..........
..........
..........
..........
'''
assert part1(data) == 4


data = '''
..........
..........
..........
....a.....
........a.
.....a....
..........
......A...
..........
..........
'''
assert part1(data) == 4


data = '''
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
'''
assert part1(data) == 14
assert part2(data) == 34


data = '''
T.........
...T......
.T........
..........
..........
..........
..........
..........
..........
..........
'''
assert part2(data) == 9


data = open('day8.in').read()
ans = part1(data)
print('part1:', ans)
ans = part2(data)
print('part2:', ans)
