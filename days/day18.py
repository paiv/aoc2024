#!/usr/bin/env python
import io
import re
import time
from collections import deque


def part1(data, w=71, h=71, n=1024):
    nums = list(map(int, re.findall(r'[+-]?\d+', data)))
    px = nums[0::2]
    py = nums[1::2]

    stones = set()
    for i,x in enumerate(px):
        if i >= n: break
        y = py[i]
        stones.add(x + 1j*y)

    grid = {(x + 1j*y) for y in range(h) for x in range(w)}
    grid -= stones

    start = 0j
    goal = (w - 1) + 1j * (h - 1)
    neib = [1, 1j, -1, -1j]

    fringe = deque([(0, start)])
    seen = set()
    ans = None

    while fringe:
        dist, pos = fringe.popleft()
        if pos == goal:
            ans = dist
            break
        if pos in seen: continue
        seen.add(pos)
        for d in neib:
            q = pos + d
            if q in grid:
                fringe.append((dist + 1, q))

    return ans


def part2(data, w=71, h=71):
    nums = list(map(int, re.findall(r'[+-]?\d+', data)))
    px = nums[0::2]
    py = nums[1::2]

    stones = set()
    grid = {(x + 1j*y) for y in range(h) for x in range(w)}

    for n in range(len(px)):
        x,y = px[n], py[n]
        stones.add(x + 1j*y)
        grid -= stones

        start = 0j
        goal = (w - 1) + 1j * (h - 1)
        neib = [1, 1j, -1, -1j]

        fringe = deque([(0, start)])
        seen = set()
        res = None

        while fringe:
            dist, pos = fringe.popleft()
            if pos == goal:
                res = dist
                break
            if pos in seen: continue
            seen.add(pos)
            for d in neib:
                q = pos + d
                if q in grid:
                    fringe.append((dist + 1, q))

        if res is None:
            return f'{x},{y}'


_palette = {
    '.': '\033[30;49m.\033[0m',
    '#': '\033[35;49m#\033[0m',
    '@': '\033[33;49m@\033[0m',
}


def display(grid, size, t=None, pois=None, inplace=True):
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
        s = '' if t is None else f'T+{t}'
        print(f'{s}\033[?25h', file=so)
        print(so.getvalue())


data = '''
5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0
'''
assert part1(data, w=7, h=7, n=12) == 22
assert part2(data, w=7, h=7) == '6,1'


def part1_path(data, n=1024):
    nums = list(map(int, re.findall(r'[+-]?\d+', data)))
    px, py = nums[0::2], nums[1::2]
    w, h = 1 + max(px), 1 + max(py)

    stones = set()
    for i,x in enumerate(px):
        if i >= n: break
        y = py[i]
        stones.add(x + 1j*y)

    grid = {(x + 1j*y) for y in range(h) for x in range(w)}
    grid -= stones

    start = 0j
    goal = (w-1) + 1j * (h-1)
    neib = [1, 1j, -1, -1j]

    fringe = deque([(0, start, (start,))])
    seen = set()
    res = None

    while fringe:
        dist, pos, path = fringe.popleft()
        if pos == goal:
            res = path
            break
        if pos in seen: continue
        seen.add(pos)
        for d in neib:
            q = pos + d
            if q in grid:
                fringe.append((dist + 1, q, path + (q,)))
    return {p:'.' for p in grid}, (w, h), res


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

    if args.part == 1:
        grid, size, path = part1_path(data, n=args.cutoff)
        if path is None: return
        for i,p in enumerate(path):
            display(grid, size, t=i, pois={p:'@'}, inplace=(i > 0))
            if soft_exit: break
            time.sleep(1 / fps)
            if i == 0:
                time.sleep(1 / fps)

    else:
        nums = list(map(int, re.findall(r'[+-]?\d+', data)))
        px, py = nums[0::2], nums[1::2]
        w, h = 1 + max(px), 1 + max(py)

        stones = set()
        grid = {(x + 1j*y):'.' for y in range(h) for x in range(w)}

        display(grid, (w, h), t=0, inplace=False)
        time.sleep(2 / fps)

        for i in range(len(px)):
            x,y = px[i], py[i]
            p = x + 1j*y
            stones.add(p)
            grid.pop(p, None)
            display(grid, (w, h), t=i+1)
            if soft_exit: break
            time.sleep(1 / fps)


def main(args):
    data = open('day18.in').read()
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
    play.add_argument('-c', '--cutoff', type=int, default=1024, help='stones limit')
    play.add_argument('--fps', type=float, default=15, help='animation speed')
    play.add_argument('file', nargs='?', default='day18.in', type=argparse.FileType(), help='problem text')
    play.set_defaults(func=handle_play)

    args = parser.parse_args()
    args.func(args)
