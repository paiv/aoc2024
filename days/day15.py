#!/usr/bin/env python
import io
import itertools
import time


def part1_parse(data):
    grid, prog = data.split('\n\n', maxsplit=1)
    lines = grid.strip().splitlines()
    w, h = len(lines[0]), len(lines)
    grid = {(x + 1j*y):c for y,s in enumerate(lines) for x,c in enumerate(s)
        if c != '#'}
    ops = {'^':-1j, 'v':1j, '<':-1, '>':1}
    prog = [ops[c] for s in prog.split() for c in s]
    start = next(p for p,c in grid.items() if c == '@')
    grid[start] = '.'
    return grid, (w, h), start, prog


def part1_frames(grid, size, start, prog):
    yield (None, grid, start)
    pos = start
    for op in prog:
        if (c := grid.get(pos + op)) is None:
            pass
        elif c == '.':
            pos += op
        elif c == 'O':
            for i in itertools.count(1):
                if (c := grid.get(pos + i * op)) is None:
                    break
                elif c == 'O':
                    pass
                elif c == '.':
                    for j in range(1, i)[::-1]:
                        grid[pos + (j+1) * op] = 'O'
                        grid[pos + j * op] = '.'
                    pos += op
                    break
                else:
                    raise Exception()
        else:
            raise Exception()
        yield (op, grid, pos)


def part1(data):
    prob = part1_parse(data)
    for _ in part1_frames(*prob):
        pass
    grid = prob[0]
    ans = sum(int(p.real + 100 * p.imag) for p,c in grid.items() if c == 'O')
    return ans


def part2_parse(data):
    grid, prog = data.split('\n\n', maxsplit=1)
    blow = {'O': '[]', '.': '..', '#': '##', '@': '@.', '\n': '\n'}
    grid = ''.join(blow[c] for c in grid)
    lines = grid.strip().splitlines()
    w, h = len(lines[0]), len(lines)
    grid = {(x + 1j*y):c for y,s in enumerate(lines) for x,c in enumerate(s)
        if c != '#'}
    ops = {'^':-1j, 'v':1j, '<':-1, '>':1}
    prog = [ops[c] for s in prog.split() for c in s]
    neib = [1, 1j, -1, -1j]
    start = next(p for p,c in grid.items() if c == '@')
    grid[start] = '.'
    return grid, (w, h), start, prog


def part2_frames(grid, size, start, prog):
    yield (None, grid, start)
    pos = start
    for op in prog:
        if (c := grid.get(pos + op)) is None:
            pass
        elif c == '.':
            pos += op
        elif c in '[]':
            if op in [1, -1]:
                for i in itertools.count(1):
                    if (c := grid.get(pos + i * op)) is None:
                        break
                    elif c in '[]':
                        pass
                    elif c == '.':
                        for j in range(1, i)[::-1]:
                            grid[pos + (j+1) * op] = grid[pos + j * op]
                            grid[pos + j * op] = '.'
                        pos += op
                        break
            else:
                fringe = [[pos]]
                while True:
                    qs = [(q + op) for q in fringe[-1]]
                    ps = [grid.get(q) for q in qs]
                    if any(c is None for c in ps):
                        break
                    elif any(c in '[]' for c in ps):
                        ws = set()
                        for q in qs:
                            if grid[q] == ']':
                                ws.add(q)
                                ws.add(q - 1)
                            elif grid[q] == '[':
                                ws.add(q)
                                ws.add(q + 1)
                        fringe.append(list(ws))
                    elif all(c == '.' for c in ps):
                        for qs in fringe[::-1]:
                            for q in qs:
                                grid[q + op] = grid[q]
                                grid[q] = '.'
                        pos += op
                        break
        else:
            raise Exception()
        yield (op, grid, pos)


def part2(data):
    prob = part2_parse(data)
    for _ in part2_frames(*prob):
        pass
    grid = prob[0]
    ans = sum(int(p.real + 100 * p.imag) for p,c in grid.items() if c == '[')
    return ans


_palette = {
    '.': '\033[30;49m.\033[0m',
    '#': '\033[30;49m#\033[0m',
    '@': '\033[95;49m@\033[0m',
    'O': '\033[36;40mO\033[0m',
    '[': '\033[33;40m[\033[0m',
    ']': '\033[33;40m]\033[0m',
    '<': '\033[30;49m<\033[0m',
    '>': '\033[30;49m>\033[0m',
    'v': '\033[30;49mv\033[0m',
    '^': '\033[30;49m^\033[0m',
    '<!': '\033[33;40m<\033[0m',
    '>!': '\033[33;40m>\033[0m',
    'v!': '\033[33;40mv\033[0m',
    '^!': '\033[33;40m^\033[0m',
}


def display(grid, size, pois=None, hist=None, inplace=True):
    w, h = size
    yup = h + 3
    if hist: yup += 1
    up = f'\033[{yup}A'
    with io.StringIO() as so:
        print('\033[?25l' + (up if inplace else ''), file=so)
        if hist:
            f = len(hist) // 2 - 1
            a,b = hist[:f], hist[f+1:]
            s = ''.join(_palette.get(c,c) for c in a)
            c = hist[f]
            s += _palette.get(c + '!', c)
            s += ''.join(_palette.get(c,c) for c in b)
            print(s, file=so)
        for y in range(h):
            for x in range(w):
                p = (x + 1j*y)
                c = grid.get(p, '#')
                if pois and p in pois:
                    c = '@'
                s = _palette.get(c, c)
                print(s, end='', file=so)
            print(file=so)
        print('\033[?25h', file=so)
        print(so.getvalue())


data = '''
########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

<^^>>>vv<v>>v<<
'''
assert part1(data) == 2028

data = '''
##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
'''
assert part1(data) == 10092
assert part2(data) == 9021


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
        prob = part1_parse(data)
        frames = part1_frames(*prob)
    elif args.part == 2:
        prob = part2_parse(data)
        frames = part2_frames(*prob)

    mop = {1:'>', -1:'<', 1j:'v', -1j:'^'}
    size, _, prog = prob[1:4]
    prog = '     ' + ''.join(mop[c] for c in prog) + '     '
    for i, (op, grid, pos) in enumerate(frames):
        display(grid, size, [pos], hist=prog[i:i+10], inplace=(i > 0))
        if soft_exit: break
        time.sleep(1 / fps)
        if i == 0:
            time.sleep(1 / fps)


def main(args):
    data = open('day15.in').read()
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
