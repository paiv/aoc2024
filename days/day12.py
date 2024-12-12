#!/usr/bin/env python
import itertools
import random
from collections import deque, Counter
from pathlib import Path
from svg import Svg


def part1(data):
    land, grid = parse_land(data)

    def perim(pts):
        ss = [(0,1), (1j, 1+1j), (0, 1j), (1, 1+1j)]
        uvn = Counter((p+u, p+v) for p in pts for u,v in ss)
        return sum(n == 1 for p,n in uvn.items())

    ans = 0
    for ps in land:
        n = len(ps)
        p = perim(ps)
        ans += n * p
    return ans


def part2(data):
    land, grid = parse_land(data)

    def perim(pts):
        ss = [(0,1), (1j, 1+1j), (0, 1j), (1, 1+1j)]
        uvn = Counter((p+u, p+v) for p in pts for u,v in ss)
        ps = {p for ks,n in uvn.items() if n == 1 for p in ks}
        seen = set()
        corners = 0
        for p in ps:
            if p in seen: continue
            seen.add(p)
            q = (
                p-1-1j in pts,
                p-1j in pts,
                p-1 in pts,
                p in pts,
            )
            t = 0
            match q:
                case (False, False, False, True): t = 1
                case (False, False, True, False): t = 1
                case (False, True, False, False): t = 1
                case (False, True, True, False): t = 2
                case (False, True, True, True): t = 1
                case (True, False, False, False): t = 1
                case (True, False, False, True): t = 2
                case (True, False, True, True): t = 1
                case (True, True, False, True): t = 1
                case (True, True, True, False): t = 1
            corners += t
        return corners

    ans = 0
    for ps in land:
        n = len(ps)
        p = perim(ps)
        ans += n * p
    return ans


def parse_land(data):
    lines = data.strip().splitlines()
    grid = {(x + 1j*y):c for y,s in enumerate(lines)
        for x,c in enumerate(s)}
    neib = [1, 1j, -1, -1j]

    land = list()
    seen = set()
    for s,c in grid.items():
        if s in seen: continue
        seen.add(s)
        chunk = set()
        fringe = deque([s])
        while fringe:
            pos = fringe.popleft()
            chunk.add(pos)
            for d in neib:
                q = pos + d
                if (k := grid.get(q)) == c:
                    if q in seen: continue
                    seen.add(q)
                    fringe.append(q)
        land.append(chunk)

    return land, grid


def render_svg(data, file=None):
    land, grid = parse_land(data)
    rs = list(range(0, 16, 3))
    palette = [f'#{r*17:02x}{g*17:02x}{b*17:02x}' for r in rs for g in rs for b in rs
        if (r,g,b) not in [(r,0,r), (r+1,0,r), (r-1,0,r), (0,0,0), (15,15,15)]]
    random.shuffle(palette)
    s = 10
    svg = Svg()
    svg['style'] = 'font:0.4em sans-serif;'
    width, height = 0, 0
    for ci, chunk in enumerate(land):
        ps = Counter()
        for p in chunk:
            width = max(width, p.real)
            height = max(height, p.imag)
            x, y = int(p.real), int(p.imag)
            svg.add_rect(x*s, y*s, s, s, fill=palette[ci % len(palette)])
            ps.update((p + y + x) for y in (0, 1j) for x in (0, 1))
        for p,n in ps.items():
            if n != 4:
                cx = s * p.real
                cy = s * p.imag
                svg.add_circle(cx, cy, s/20, fill='#f0f')
        for p in chunk:
            x, y = s * (p.real + 0.2), s * (p.imag + 0.7)
            svg.add_text(x, y, grid[p])
    w, h = int(width)+1, int(height)+1
    svg.viewbox = (0, 0, w*s, h*s)
    if file is not None:
        svg.prettyprint(file)
    else:
        return str(svg)


def dump_around(pos, grid):
    px, py = int(pos.real), int(pos.imag)
    for y in range(py - 5, py + 6):
        for x in range(px - 5, px + 6):
            q = x + 1j*y
            s = grid.get(q, '.')
            if q == pos:
                s = f'\033[41;37m{s}\033[0m'
            print(s, end='')
        print()


data = '''
AAAA
BBCD
BBCC
EEEC
'''
assert part1(data) == 140
assert part2(data) == 80

data = '''
OOOOO
OXOXO
OOOOO
OXOXO
OOOOO
'''
assert part1(data) == 772
assert part2(data) == 436

data = '''
RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
'''
assert part1(data) == 1930
assert part2(data) == 1206

data = '''
EEEEE
EXXXX
EEEEE
EXXXX
EEEEE
'''
assert part2(data) == 236

data = '''
AAXXX
AAXAX
AAAAX
AAXAX
AAXXX
'''
assert part1(data) == 572
assert part2(data) == 300

data = '''
AAAA
ABCA
ABCA
AAAD
'''
assert part1(data) == 292

data = '''
HHHHHHH
HoooooH
HoHHHoH
HoHoHoH
HHHoHHH
'''
assert part1(data) == 1344
assert part2(data) == 464


def main(args):
    fn = 'day12.in'
    if args.file:
        fn = args.file
    else:
        fn = Path(fn).open()

    data = fn.read()
    ans = part1(data)
    print('part1:', ans)
    ans = part2(data)
    print('part2:', ans)

    if args.image_output:
        with Path(args.image_output).open('w') as fp:
            render_svg(data, file=fp)


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--image-output', help='render SVG image')
    parser.add_argument('file', nargs='?', type=argparse.FileType(), help='problem file')
    args = parser.parse_args()
    main(args)

