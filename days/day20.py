#!/usr/bin/env python
from collections import deque


def part1(data, N=100, T=2):
    lines = data.strip().splitlines()
    w, h = len(lines[0]), len(lines)
    grid = {(x + 1j*y):c for y,s in enumerate(lines) for x,c in enumerate(s)
        if c != '#'}
    start = next(p for p, c in grid.items() if c == 'S')
    goal = next(p for p, c in grid.items() if c == 'E')
    neib = [1, 1j, -1, -1j]

    def find_paths(start):
        fringe = deque([(0, start)])
        seen = dict()
        while fringe:
            dt, pos = fringe.popleft()
            if pos in seen: continue
            seen[pos] = dt
            for d in neib:
                if (q := pos + d) in grid:
                    fringe.append((dt + 1, q))
        return seen

    from_start = find_paths(start)
    to_end = find_paths(goal)
    base = from_start[goal]
    ans = 0

    for pos, dt in from_start.items():
        for n in range(1, T+1):
            for x in range(-n, n+1):
                for y in [n - abs(x), -n + abs(x)]:
                    q = pos + (x + 1j * y)
                    if (w := to_end.get(q)) is not None:
                        ans += base - (dt + n + w) >= N
                    if not y: break
    return ans


def part2(data, N=100):
    return part1(data, N, T=20)


data = '''
###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############
'''
assert part1(data, N=38) == 3
assert part2(data, N=76) == 3


data = open('day20.in').read()
ans = part1(data)
print('part1:', ans)
ans = part2(data)
print('part2:', ans)
