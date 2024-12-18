#!/usr/bin/env python
import re


def vm_run(prog, regs):
    regs = list(regs)
    ra, rb, rc = 4, 5, 6

    def _arg(v):
        match v:
            case 4 | 5 | 6:
                return regs[v - 4]
            case _:
                return v

    def _set(r, v):
        regs[r - 4] = v

    pn = len(prog)
    so = list()
    ip = 0
    while 0 <= ip < pn:
        op, val = prog[ip:ip+2]
        match op:
            case 0:
                _set(ra, _arg(ra) >> _arg(val))
                ip += 2
            case 1:
                _set(rb, _arg(rb) ^ val)
                ip += 2
            case 2:
                _set(rb, _arg(val) % 8)
                ip += 2
            case 3:
                if _arg(ra):
                    ip = val
                else:
                    ip += 2
            case 4:
                _set(rb, _arg(rb) ^ _arg(rc))
                ip += 2
            case 5:
                so.append(_arg(val) % 8)
                ip += 2
            case 6:
                _set(rb, _arg(ra) >> _arg(val))
                ip += 2
            case 7:
                _set(rc, _arg(ra) >> _arg(val))
                ip += 2
            case _:
                raise Exception(f'unhandled {op=!r} {arg=!r}')
    return so


def disasm(prog, file=None):
    comb = {4: 'ra', 5: 'rb', 6: 'rc'}
    for ip in range(0, len(prog), 2):
        op, val = prog[ip:ip+2]
        arg = comb.get(val, val)
        print(f'{ip:03o}: {op} {val}  ', end='', file=file)
        match op:
            case 0:
                print(f'(adv) ra <<= {arg}', file=file)
            case 1:
                print(f'(bxl) rb ^= {val}', file=file)
            case 2:
                print(f'(bst) rb = {arg} % 8', file=file)
            case 3:
                print(f'(jnz) {val}', file=file)
            case 4:
                print(f'(bxc) rb ^= rc', file=file)
            case 5:
                print(f'(out) {arg} % 8', file=file)
            case 6:
                print(f'(bdv) rb = ra << {arg}', file=file)
            case 7:
                print(f'(cdv) rc = ra << {arg}', file=file)
            case _:
                raise Exception(f'unhandled {op=!r} {val=!r}')
 
def vm_parse(data):
    regs = list(map(int, re.findall(r'[ABC]: (\d+)', data)))
    prog = list(map(int, re.findall(r'\d+', data.split('Program:')[-1])))
    return prog, regs


def part1(data):
    prog, regs = vm_parse(data)
    res = vm_run(prog, regs)
    ans = ','.join(map(str, res))
    return ans


def part2(data):
    def rev(prog, acc):
        if not prog:
            yield acc
        else:
            p = prog[-1]
            for i in range(8):
                a = ((acc << 3) | i) >> (i ^ 3)
                if (a % 8) ^ i == p:
                    yield from rev(prog[:-1], (acc << 3) | i)

    prog, regs = vm_parse(data)
    #disasm(prog)
    ans = None
    for ans in rev(prog, 0):
        regs[0] = ans
        res = vm_run(prog, regs)
        if res == prog:
            break
    return ans


data = '''
Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0
'''
assert part1(data) == '4,6,3,5,6,3,5,2,1,0'


def handle_disasm(args):
    data = args.file.read()
    prog, _ = vm_parse(data)
    disasm(prog)


def handle_sat(args):
    import z3
    data = args.file.read()
    prog, _ = vm_parse(data)

    opt = z3.Optimize()
    s = z3.BitVec('s', len(prog) * 3)
    ra, rb, rc = s, 0, 0

    for x in prog:
        for ip in range(0, len(prog), 2):
            comb = {4: ra, 5: rb, 6: rc}
            op, val = prog[ip:ip+2]
            arg = comb.get(val, val)
            match op:
                case 0:
                    ra = ra / (1 << arg)
                case 1:
                    rb = rb ^ val
                case 2:
                    rb = arg % 8
                case 3:
                    pass
                case 4:
                    rb = rb ^ rc
                case 5:
                    opt.add((arg % 8) == x)
                case 6:
                    rb = ra / (1 << arg)
                case 7:
                    rc = ra / (1 << arg)
    opt.add(ra == 0)

    res = opt.check()
    assert res == z3.sat, repr(res)
    ans = opt.model().eval(s).as_long()

    assert vm_run(prog, [ans,0,0]) == prog
    print(ans)


def main(args):
    fp = args.file if 'file' in args else open('day17.in')
    data = fp.read()
    ans = part1(data)
    print('part1:', ans)
    ans = part2(data)
    print('part2:', ans)


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.set_defaults(func=main)
    subp = parser.add_subparsers()

    filep = subp.add_parser('file')
    filep.add_argument('file', nargs='?', type=argparse.FileType(), default='day17.in', help='problem text')
    filep.set_defaults(func=main)

    dasmp = subp.add_parser('disasm', aliases=['dasm', 'asm'])
    dasmp.add_argument('file', nargs='?', type=argparse.FileType(), default='day17.in', help='problem text')
    dasmp.set_defaults(func=handle_disasm)

    sat = subp.add_parser('z3', aliases=['sat'])
    sat.add_argument('file', nargs='?', type=argparse.FileType(), default='day17.in', help='problem text')
    sat.set_defaults(func=handle_sat)

    args = parser.parse_args()
    args.func(args)
