#!/usr/bin/env python
import re
from collections import deque


# https://aoc.infi.nl/2024

def xm4s_parse(text):
    srx = r'\b(?:push\s+(X)|push\s+(Y)|push\s+(Z)|push\s+(\-?\d+)|(add)|jmpos\s+(\-?\d+)|(ret)|(\w+))\b'
    prog = list()
    for m in re.finditer(srx, data, re.I):
        match m.lastindex:
            case 1: # push X
                prog.append((1, m[1].lower()))
            case 2: # push Y
                prog.append((2, m[2].lower()))
            case 3: # push Z
                prog.append((3, m[3].lower()))
            case 4: # push int
                prog.append((4, int(m[4])))
            case 5: # add
                prog.append((5, None))
            case 6: # jmp
                prog.append((6, int(m[6])))
            case 7: # ret
                prog.append((7, None))
            case 8:
                raise Exception(f'unhandled op {m[0]!r}')
    return prog


def xm4s_run(prog, addr):
    x,y,z = addr
    n = len(prog)
    stack = list()
    ip = 0
    while 0 <= ip < n:
        op, arg = prog[ip]
        match op:
            case 1: stack.append(x)
            case 2: stack.append(y)
            case 3: stack.append(z)
            case 4: stack.append(arg)
            case 5: stack.append(stack.pop() + stack.pop())
            case 6: ip += arg if stack.pop() >= 0 else 0
            case 7: return stack.pop()
        ip += 1


def part1(data):
    prog = xm4s_parse(data)
    state = {(x,y,z):0 for x in range(30) for y in range(30) for z in range(30)}
    for p in state:
        state[p] = xm4s_run(prog, p)

    # sneeuwtotaal
    ans = sum(state.values())
    return ans


def part2(data):
    prog = xm4s_parse(data)
    state = {(x,y,z):0 for x in range(30) for y in range(30) for z in range(30)}
    for p in state:
        state[p] = xm4s_run(prog, p)

    neib = [
        (1, 0, 0), (-1, 0, 0),
        (0, 1, 0), (0, -1, 0),
        (0, 0, 1), (0, 0, -1),
    ]

    state = [p for p,v in state.items() if v > 0]
    seen = set()

    def walk(start):
        fringe = deque([start])
        res = 0
        while fringe:
            pos = fringe.popleft()
            if pos in seen: continue
            seen.add(pos)
            res = 1
            x,y,z = pos
            for dx,dy,dz in neib:
                q = (x+dx, y+dy, z+dz)
                if q in state:
                    fringe.append(q)
        return res

    ans = sum(map(walk, state))
    return ans


data = '''
push 999
push x
push -3
add
jmpos 2
ret
ret
push 123
ret
'''
assert part1(data) == 5686200


data = open('infi.in').read()
ans = part1(data)
print(f'part1: {ans}')
ans = part2(data)
print(f'part2: {ans}')
