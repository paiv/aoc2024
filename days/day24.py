#!/usr/bin/env python
import re
from collections import defaultdict


def parse_grid(data):
    gates, data = data.strip().split('\n\n')
    gates = {k.strip():(int(v) != 0) for s in gates.splitlines() for k,v in [s.split(': ')]}
   
    grid = dict()
    wires = defaultdict(set)
    for a, op, b, t in re.findall(r'(\w+) (AND|OR|XOR) (\w+) -> (\w+)', data):
        grid[t] = (a, op, b)
        wires[a].add(t)
        wires[b].add(t)

    gates = {k:False for k in grid} | gates
    return grid, wires, gates


def part1(data):
    grid, wires, gates = parse_grid(data)
    ops = {
        'AND': bool.__and__,
        'OR': bool.__or__,
        'XOR': bool.__xor__,
    }

    def probe(grid, gates, k):
        if (ps := grid.get(k)):
            a, op, b = grid[k]
            return ops[op](gates[a], gates[b])
        else:
            return gates[k]

    prev = None
    while prev != gates:
        wave = dict()
        for k, v in gates.items():
            wave[k] = probe(grid, gates, k)
        prev, gates = gates, wave

    ans = 0
    for i in range(len(gates)):
        if (v := gates.get(f'z{i:02}')) is None:
            break
        ans += v * (1 << i)
    return ans


def part2(data):
    grid, wires, gates = parse_grid(data)
    ops = {
        'AND': bool.__and__,
        'OR': bool.__or__,
        'XOR': bool.__xor__,
    }
    
    def probe(grid, gates, k):
        if (ps := grid.get(k)):
            a, op, b = grid[k]
            return ops[op](gates[a], gates[b])
        else:
            return gates[k]

    def powerup(grid, gates):
        prev = None
        while prev != gates:
            wave = dict()
            for k, v in gates.items():
                wave[k] = probe(grid, gates, k)
            prev, gates = gates, wave
        return gates

    def read_bits(gates, p):
        res = list()
        for i in range(len(gates)):
            if (v := gates.get(f'{p}{i:02}')) is None:
                break
            res.append(v)
        return res

    def read_int(gates, p):
        ts = read_bits(gates, p)
        return sum(x * (1 << i) for i,x in enumerate(ts))

    bits = sum(k[0] == 'x' for k in gates)

    def do_sum(grid, x, y):
        gates = {p:False for p in grid}
        for i in range(bits):
            gates[f'x{i:02}'] = bool(x & 1)
            gates[f'y{i:02}'] = bool(y & 1)
            x >>= 1
            y >>= 1
        gates = powerup(grid, gates)
        return read_int(gates, 'z'), gates

    def valid(i):
        for x in [0, 1 << i]:
            for y in [0, 1 << i]:
                c = bool(((x + y) >> i) & 1)
                _, gs = do_sum(grid, x, y)
                vs = read_bits(gs, 'z')
                if vs[i] != c:
                    return False
        return True

    def find_fix(i):
        x, y, z = (f'{c}{i:02}' for c in 'xyz')
        nx, na = wires[x]
        if grid[nx][1] != 'XOR':
            nx, na = na, nx
        assert grid[nx][1] == 'XOR'
        assert grid[na][1] == 'AND'

        if z not in wires[nx]:
            for q in wires[nx]:
                if grid[q][1] == 'XOR':
                    return q, z
            return nx, na
        if grid[z][1] != 'XOR':
            for q in wires[nx]:
                if grid[q][1] == 'XOR':
                    return q, z
        raise Exception()

    swaps = set()
    for i in range(bits):
        if not valid(i):
            a,b = find_fix(i)
            grid[a], grid[b] = grid[b], grid[a]
            swaps |= {a, b}

    assert do_sum(grid, 16505452623174, 7668612819043)[0] == 24174065442217

    ans = ','.join(sorted(swaps))
    return ans


data = '''
x00: 1
x01: 1
x02: 1
y00: 0
y01: 1
y02: 0

x00 AND y00 -> z00
x01 XOR y01 -> z01
x02 OR y02 -> z02
'''
assert part1(data) == 4

data = '''
x00: 1
x01: 0
x02: 1
x03: 1
x04: 0
y00: 1
y01: 1
y02: 1
y03: 1
y04: 1

ntg XOR fgs -> mjb
y02 OR x01 -> tnw
kwq OR kpj -> z05
x00 OR x03 -> fst
tgd XOR rvg -> z01
vdt OR tnw -> bfw
bfw AND frj -> z10
ffh OR nrd -> bqk
y00 AND y03 -> djm
y03 OR y00 -> psh
bqk OR frj -> z08
tnw OR fst -> frj
gnj AND tgd -> z11
bfw XOR mjb -> z00
x03 OR x00 -> vdt
gnj AND wpb -> z02
x04 AND y00 -> kjc
djm OR pbm -> qhw
nrd AND vdt -> hwm
kjc AND fst -> rvg
y04 OR y02 -> fgs
y01 AND x02 -> pbm
ntg OR kjc -> kwq
psh XOR fgs -> tgd
qhw XOR tgd -> z09
pbm OR djm -> kpj
x03 XOR y03 -> ffh
x00 XOR y04 -> ntg
bfw OR bqk -> z06
nrd XOR fgs -> wpb
frj XOR qhw -> z04
bqk OR frj -> z07
y03 OR x01 -> nrd
hwm AND bqk -> z03
tgd XOR rvg -> z12
tnw OR pbm -> gnj
'''
assert part1(data) == 2024


def handle_graph(args):
    import io
    data = args.file.read()
    grid, wires, gates = parse_grid(data)

    palette = {
        'x': 'lightgreen',
        'y': 'pink',
        'z': 'lightskyblue',
    }

    with io.StringIO() as so:
        print('digraph {', file=so)
        print('node [style=filled, fillcolor=white]', file=so)
        for k in gates:
            if (q := k[0]) in 'xy':
                c = palette[q]
                print(f'{k} [fillcolor={c}]', file=so)
            elif q == 'z':
                c = palette[q]
                print(f'{k}o [label={k}, fillcolor={c}]', file=so)
        for k, ps in grid.items():
            a, op, b = ps
            print(f'{k} [label={op}]', file=so)
            print(f'{a} -> {k}', file=so)
            print(f'{b} -> {k}', file=so)
            if k[0] == 'z':
                print(f'{k} -> {k}o', file=so)
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
    parser.add_argument('-f', '--file', default='day24.in', type=argparse.FileType(), help='problem text')
    parser.set_defaults(func=main)
    subp = parser.add_subparsers()

    grap = subp.add_parser('graph')
    grap.set_defaults(func=handle_graph)

    args = parser.parse_args()
    args.func(args)
