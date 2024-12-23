#!/usr/bin/env python
from collections import defaultdict


def parse_graph(data):
    data = [s.split('-') for s in data.strip().splitlines()]
    g = defaultdict(set)
    for a,b in data:
        g[a].add(b)
        g[b].add(a)
    return g


def part1(data):
    g = parse_graph(data)

    ts = set()
    for k,ps in g.items():
        if k[0] != 't': continue
        for a in ps:
            for b in g[a]:
                if k in g[b]:
                    ts.add(','.join(sorted([k,a,b])))
    ans = len(ts)
    return ans


def part2(data):
    g = parse_graph(data)

    def clique(s):
        for k, ps in g.items():
            if s & ps == s:
                s.add(k)
        return s

    best = 0
    for k, ps in g.items():
        seen = set()
        for a in ps:
            for b in g[a]:
                if k in g[b]:
                    s = ','.join(sorted([k, a, b]))
                    if s in seen: continue
                    seen.add(s)
                    q = clique({k, a, b})
                    if len(q) > best:
                        best = len(q)
                        ans = ','.join(sorted(q))
    return ans


data = '''
kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn
'''
assert part1(data) == 7
assert part2(data) == 'co,de,ka,ta'


def handle_graph(args):
    import io
    data = args.file.read()
    g = parse_graph(data)

    with io.StringIO() as so:
        print('graph {', file=so)
        seen = set()
        for k, ps in g.items():
            s = ','.join(ps - seen)
            if s:
                if ',' in s:
                    s = f'{{{s}}}'
                print(f'  {k} -- {s}', file=so)
            seen.add(k)
        print('}', end='', file=so)
        print(so.getvalue())


def main(args):
    data = args.file.read()
    ans = part1(data)
    print('part1:', ans)
    ans = part2(data)
    print('part2:', ans)


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--file', default='day23.in', type=argparse.FileType(), help='problem text')
    parser.set_defaults(func=main)
    subp = parser.add_subparsers()

    grap = subp.add_parser('graph')
    grap.set_defaults(func=handle_graph)

    args = parser.parse_args()
    args.func(args)
