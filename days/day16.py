#!/usr/bin/env python
import heapq
import io
import itertools
import time


def part1(data):
    lines = data.strip().splitlines()
    grid = {(x + 1j*y):c for y,s in enumerate(lines) for x,c in enumerate(s)
        if c != '#'}
    start = next(p for p, c in grid.items() if c == 'S')
    goal = next(p for p, c in grid.items() if c == 'E')

    path = [(start, 1)]
    fringe = [(0, 0)]
    seen = set()

    while fringe:
        dist, ip = heapq.heappop(fringe)
        pos, dr = path[ip]

        if pos == goal:
            ans = dist
            break

        if (pos, dr) in seen: continue
        seen.add((pos, dr))

        if (q := pos + dr) in grid:
            heapq.heappush(fringe, (dist + 1, len(path)))
            path.append((q, dr))

        for i in range(3):
            dr *= 1j
            heapq.heappush(fringe, (dist + 1000, len(path)))
            path.append((pos, dr))

    return ans


def part2(data):
    lines = data.strip().splitlines()
    grid = {(x + 1j*y):c for y,s in enumerate(lines) for x,c in enumerate(s)
        if c != '#'}
    start = next(p for p, c in grid.items() if c == 'S')
    goal = next(p for p, c in grid.items() if c == 'E')
    inf = float('inf')

    best = inf
    path = [(start, 1)]
    prev = list()
    terms = list()
    fringe = [(0, -1, 0)]
    seen = dict()

    while fringe:
        dist, fr, ip = heapq.heappop(fringe)
        pos, dr = path[ip]

        if dist > best: break
        if pos == goal:
            if dist < best:
                best = dist
                terms = list()
            terms.append((fr, pos))

        if seen.get((pos, dr), inf) < dist: continue
        seen[pos, dr] = dist

        if (q := pos + dr) in grid:
            heapq.heappush(fringe, (dist + 1, len(prev), len(path)))
            path.append((q, dr))
            prev.append((fr, pos))

        for _ in range(3):
            dr *= 1j
            heapq.heappush(fringe, (dist + 1000, len(prev), len(path)))
            path.append((pos, dr))
            prev.append((fr, pos))

    res = set()
    for i,p in terms:
        while i >= 0:
            res.add(p)
            i,p = prev[i]

    ans = len(res)
    return ans


data = '''
###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############
'''
assert part1(data) == 7036
assert part2(data) == 45

data = '''
#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################
'''
assert part1(data) == 11048
assert part2(data) == 64


def calc_paths(data):
    lines = data.strip().splitlines()
    grid = {(x + 1j*y):c for y,s in enumerate(lines) for x,c in enumerate(s)
        if c != '#'}
    start = next(p for p, c in grid.items() if c == 'S')
    goal = next(p for p, c in grid.items() if c == 'E')
    inf = float('inf')

    best = inf
    path = [(start, 1)]
    prev = list()
    terms = list()
    fringe = [(0, -1, 0)]
    seen = dict()

    while fringe:
        dist, fr, ip = heapq.heappop(fringe)
        pos, dr = path[ip]

        if dist > best: break
        if pos == goal:
            if dist < best:
                best = dist
                terms = list()
            terms.append((fr, ip))

        if seen.get((pos, dr), inf) < dist: continue
        seen[pos, dr] = dist

        if (q := pos + dr) in grid:
            heapq.heappush(fringe, (dist + 1, len(prev), len(path)))
            prev.append((fr, len(path)))
            path.append((q, dr))

        for _ in range(3):
            dr *= 1j
            heapq.heappush(fringe, (dist + 1000, len(prev), len(path)))
            prev.append((fr, len(path)))
            path.append((pos, dr))

    res = list()
    for i,p in terms:
        ps = list()
        while i >= 0:
            ps.append(path[p])
            i,p = prev[i]
        res.append(ps[::-1])
    return grid, res


_palette = {
    '.': '\033[30;49m.\033[0m',
    '#': '\033[30;49m#\033[0m',
    '<': '\033[33;49m<\033[0m',
    '>': '\033[33;49m>\033[0m',
    'v': '\033[33;49mv\033[0m',
    '^': '\033[33;49m^\033[0m',
}


def display(grid, size, pois=None, inplace=True):
    w, h = size
    yup = h + 3
    up = f'\033[{yup}A'
    with io.StringIO() as so:
        print('\033[?25l' + (up if inplace else ''), file=so)
        for y in range(h):
            for x in range(w):
                p = (x + 1j*y)
                c = grid.get(p, '#')
                if pois and (k := pois.get(p)):
                    c = k
                s = _palette.get(c, c)
                print(s, end='', file=so)
            print(file=so)
        print('\033[?25h', file=so)
        print(so.getvalue())


def handle_play(args):
    import signal

    soft_exit = False
    def handler(signum, frame):
        nonlocal soft_exit
        soft_exit = True
    signal.signal(signal.SIGINT, handler)

    fps = args.fps
    if fps <= 0:
        fps = 1

    data = args.file.read()
    print('calculating...')
    grid, paths = calc_paths(data)
    w = 2 + max(int(p.real) for p in grid)
    h = 2 + max(int(p.imag) for p in grid)

    if args.part == 1:
        paths = paths[:1]
    for i, ps in enumerate(paths, 1):
        ps[:0] = [None] * i * 2

    mop = {1:'>', -1:'<', 1j:'v', -1j:'^'}
    for i, (ps) in enumerate(itertools.zip_longest(*paths)):
        poi = dict()
        for pos,dr in filter(None, ps):
            poi[pos] = mop[dr]
        display(grid, (w, h), poi, inplace=(i > 0))
        if soft_exit: break
        time.sleep(1 / fps)
        if i == 0:
            time.sleep(1 / fps)


def main(args):
    data = open('day16.in').read()
    ans = part1(data)
    print('part1:', ans)
    ans = part2(data)
    print('part2:', ans)


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.set_defaults(func=main)
    subp = parser.add_subparsers()

    play = subp.add_parser('play')
    play.add_argument('-p', '--part', type=int, choices=(1,2), default=1, help='problem part')
    play.add_argument('--fps', type=float, default=2, help='animation speed')
    play.add_argument('file', type=argparse.FileType(), help='problem text')
    play.set_defaults(func=handle_play)

    args = parser.parse_args()
    args.func(args)
