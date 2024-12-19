#!/usr/bin/env python
from functools import cache


def part1(data):
    avail, data = data.split('\n\n')
    lines = data.strip().splitlines()
    avail = [s.rstrip(',') for s in avail.split()]

    @cache
    def check(s):
        if not s: return True
        for p in avail:
            if s.startswith(p):
                if check(s[len(p):]):
                    return True
        return False

    ans = sum(map(check, lines))
    return ans


def part2(data):
    avail, data = data.split('\n\n')
    lines = data.strip().splitlines()
    avail = [s.rstrip(',') for s in avail.split()]
    avail = sorted(avail, key=lambda s: (-len(s), s))

    @cache
    def check(s):
        if not s: return 1
        res = 0
        for p in avail:
            if s.startswith(p):
                res += check(s[len(p):])
        return res

    ans = sum(map(check, lines))
    return ans


data = '''
r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb
'''
assert part1(data) == 6
assert part2(data) == 16


def main(args):
    data = args.file.read()
    ans = part1(data)
    print('part1:', ans)
    ans = part2(data)
    print('part2:', ans)


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('file', nargs='?', default='day19.in', type=argparse.FileType(), help='problem text')
    args = parser.parse_args()
    main(args)
