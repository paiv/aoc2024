#!/usr/bin/env python
import re


def part1(data, N=0):
    lines = data.strip().splitlines()
    data = list(map(int, re.findall(r'[+-]?\d+', data)))
    ax = data[0::6]
    ay = data[1::6]
    bx = data[2::6]
    by = data[3::6]
    px = data[4::6]
    py = data[5::6]

    # ax*a + bx*b = px
    # ay*a + by*b = py
    # a = (px - bx*b) / ax
    # a = (py - by*b) / ay
    # ay*(px - bx*b) = ax*(py - by*b)
    # ay*px - ax*py = ay*bx*b - ax*by*b
    # b = (ay*px - ax*py) / (ay*bx - ax*by)

    ans = 0
    for i, a in enumerate(ax):
        u = ((px[i] + N) * ay[i] - (py[i] + N) * ax[i]) / (ay[i] * bx[i] - ax[i] * by[i])
        v = ((px[i] + N) - bx[i] * u) / ax[i]
        if u.is_integer() and v.is_integer():
            ans += int(u) + 3 * int(v)

    return ans


def part2(data, N=10000000000000):
    return part1(data, N)


data = '''
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
'''
assert part1(data) == 480


data = open('day13.in').read()
ans = part1(data)
print('part1:', ans)
ans = part2(data)
print('part2:', ans)
