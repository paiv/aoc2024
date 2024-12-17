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
        val = _arg(val)
        match op:
            case 0:
                _set(ra, _arg(ra) >> val)
                ip += 2
            case 1:
                _set(rb, _arg(rb) ^ val)
                ip += 2
            case 2:
                _set(rb, val % 8)
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
                so.append(val % 8)
                ip += 2
            case 6:
                _set(rb, _arg(ra) >> val)
                ip += 2
            case 7:
                _set(rc, _arg(ra) >> val)
                ip += 2
            case _:
                raise Exception(f'unhandled {op=!r} {arg=!r}')
    return so


def disasm(prog, file=None):
    rms = {4: 'ra', 5: 'rb', 6: 'rc'}
    ip = 0
    while 0 <= ip < len(prog):
        op, val = prog[ip:ip+2]
        arg = rms.get(val, val)
        print(f'{ip:03o}: {op} {val}  ', end='', file=file)
        match op:
            case 0:
                print(f'(adv) ra <<= {arg}', file=file)
                ip += 2
            case 1:
                print(f'(bxl) rb ^= {arg}', file=file)
                ip += 2
            case 2:
                print(f'(bst) rb = {arg} % 8', file=file)
                ip += 2
            case 3:
                print(f'(jnz) {arg}', file=file)
                ip += 2
            case 4:
                print(f'(bxc) rb ^= rc', file=file)
                ip += 2
            case 5:
                print(f'(out) {arg} % 8', file=file)
                ip += 2
            case 6:
                print(f'(bdv) rb = ra << {arg}', file=file)
                ip += 2
            case 7:
                print(f'(cdv) rc = ra << {arg}', file=file)
                ip += 2
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


def main(args):
    data = open('day17.in').read()
    ans = part1(data)
    print('part1:', ans)
    ans = part2(data)
    print('part2:', ans)


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.set_defaults(func=main)
    subp = parser.add_subparsers()

    dasmp = subp.add_parser('disasm', aliases=['dasm', 'asm'])
    dasmp.add_argument('file', type=argparse.FileType(), help='problem text')
    dasmp.set_defaults(func=handle_disasm)

    args = parser.parse_args()
    args.func(args)
