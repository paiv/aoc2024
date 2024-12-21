#!/usr/bin/env python
import io
import itertools
import time
from collections import Counter


num_keypad = '''
789
456
123
.0A
'''

dir_keypad = '''
.^A
<v>
'''


def parse_pad(text):
    return {(x + 1j*y):c for y,s in enumerate(text.strip().splitlines())
        for x,c in enumerate(s) if c != '.'}


def pad_paths():
    numke, dirke = parse_pad(num_keypad), parse_pad(dir_keypad)

    def path_hv(start, goal):
        w = goal - start
        h = '>' * int(w.real) + '<' * -int(w.real)
        v = 'v' * int(w.imag) + '^' * -int(w.imag)
        return (h + v, v + h)

    def find_paths(grid):
        res = dict()
        for start,s in grid.items():
            for goal,t in grid.items():
                if start == goal:
                    res[s, t] = ''
                    continue
                phv, pvh = path_hv(start, goal)
                w = goal - start
                ps = None
                if (w.real > 0) and (start + 1j*w.imag) in grid:
                    ps = pvh
                elif w.real and (start + w.real) in grid:
                    ps = phv
                elif w.imag and (start + 1j*w.imag) in grid:
                    ps = pvh
                res[s, t] = ps
        return res

    numps = find_paths(numke)
    dirps = find_paths(dirke)
    return numps, dirps


def encode(num, N):
    def expand_path(paths, seq):
        so = ''
        pos = 'A'
        for c in seq:
            so += paths[pos, c] + 'A'
            pos = c
        return so

    def inner(paths, alt, deep):
        if deep == 0:
            return alt
        s = expand_path(paths, alt)
        return inner(dir_paths, s, deep - 1)

    num_paths, dir_paths = pad_paths()
    return inner(num_paths, num, N+1)


def part1(data, N=2):
    ans = 0
    for num in data.strip().splitlines():
        ans += int(num[:-1]) * len(encode(num, N))
    return ans


def part2(data, N=25):
    num_paths, dir_paths = pad_paths()

    def encode(num):
        def expand_path0(paths, seq):
            so = ''
            pos = 'A'
            for c in seq:
                so += paths[pos, c] + 'A'
                pos = c
            return so

        def expand_path(paths, seq, n):
            so = Counter()
            pos = 'A'
            for c in seq:
                p = paths[pos, c] + 'A'
                so[p] += n
                pos = c
            return so

        def inner(alt, deep):
            if deep == 0:
                return alt
            so = Counter()
            for chk, n in alt.items():
                so += expand_path(dir_paths, chk, n)
            return inner(so, deep - 1)

        s = expand_path0(num_paths, num)
        t = inner({s:1}, N)
        return sum(v * len(k) for k,v in t.items())

    ans = 0
    for line in data.strip().splitlines():
        ans += int(line[:-1]) * encode(line)
    return ans


_palette = {
    '.': '\033[30;49m.\033[0m',
    'A': '\033[35;49mA\033[0m',
    '<': '\033[33;49m<\033[0m',
    '>': '\033[33;49m>\033[0m',
    'v': '\033[33;49mv\033[0m',
    '^': '\033[33;49m^\033[0m',
}


def render_grid(grid, poi):
    maxx = max(int(p.real) for p in grid)
    maxy = max(int(p.imag) for p in grid)
    with io.StringIO() as so:
        for y in range(maxy+1):
            for x in range(maxx+1):
                p = (x + 1j*y)
                c = grid.get(p, '.')
                c = _palette.get(c, c)
                s = f'[{c}]' if p == poi else f' {c} '
                print(s, end='', file=so)
            print(file=so)
        return so.getvalue()


def horiz(*args):
    res = list()
    for ps in itertools.zip_longest(*(s.splitlines() for s in args)):
        res.append('    '.join(s or '         ' for s in ps))
    return '\n'.join(res)


def display(numke, dirke, p4, p3, p2, p1, inplace=True):
    pad4 = render_grid(dirke, p4)
    pad3 = render_grid(dirke, p3)
    pad2 = render_grid(dirke, p2)
    pad1 = render_grid(numke, p1)
    text = horiz(pad4, pad3, pad2, pad1)
    yup = 7
    up = f'\033[{yup}A'
    with io.StringIO() as so:
        print('\033[?25l' + (up if inplace else ''), file=so)
        print(text, file=so)
        print('\033[?25h', file=so)
        return so.getvalue()


def replay(prog):
    neib = [1, 1j, -1, -1j]
    keymap = dict(zip('A>v<^', [10] + neib))
    numke, dirke = parse_pad(num_keypad), parse_pad(dir_keypad)
    num_keys = {c:p for p,c in numke.items()}
    dir_keys = {c:p for p,c in dirke.items()}
    p1 = num_keys['A']
    p2 = dir_keys['A']
    p3 = dir_keys['A']
    yield display(numke, dirke, p3, p3, p2, p1, inplace=False)
    for o4 in prog:
        if o4 == 'A':
            if (o3 := dirke[p3]) == 'A':
                if (o2 := dirke[p2]) == 'A':
                    k = numke[p1]
                    #print(f'|{k}|')
                else:
                    p1 += keymap[o2]
            else:
                p2 += keymap[o3]
        else:
            p3 += keymap[o4]
        yield display(numke, dirke, dir_keys[o4], p3, p2, p1)


data = '''
029A
980A
179A
456A
379A
'''
assert part1(data) == 126384
assert part2(data, N=2) == 126384


def handle_play(args):
    import signal

    soft_exit = False
    def handler(signum, frame):
        nonlocal soft_exit
        if soft_exit: exit(signum)
        soft_exit = True
    signal.signal(signal.SIGINT, handler)

    fps = args.fps
    if not fps:
        fps = 1

    for num in data.strip().splitlines():
        prog = encode(num, N=2)
        print(num)
        print(f'({len(prog)})', ''.join(prog))
        for frame in replay(prog):
            print(frame)

            if soft_exit: break
            soft_exit = True
            time.sleep(1 / fps)
            soft_exit = False


def main(args):
    data = args.file.read()
    ans = part1(data)
    print('part1:', ans)
    ans = part2(data)
    print('part2:', ans)


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--file', default='day21.in', type=argparse.FileType(), help='problem text')
    parser.set_defaults(func=main)
    subp = parser.add_subparsers()

    play = subp.add_parser('play')
    play.add_argument('--fps', type=float, default=2, help='animation speed')
    play.add_argument('file', type=argparse.FileType(), help='problem text')
    play.set_defaults(func=handle_play)

    args = parser.parse_args()
    args.func(args)
