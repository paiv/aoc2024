#!/usr/bin/env python
import re


def part1(data):
    ans = 0
    for x,y in re.findall(r'mul\((\d+),(\d+)\)', data):
        ans += int(x) * int(y)
    return ans


def part2(data):
    ans = 0
    state = True
    for m,x,y in re.findall(r"(do\(\)|mul\((-?\d+),(-?\d+)\)|don't\(\))", data):
        match m[:3]:
            case 'don':
                state = False
            case 'do(':
                state = True
            case 'mul' if state:
                ans += int(x) * int(y)
    return ans


data = '''
xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
'''
assert part1(data) == 161

data = '''
xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
'''
assert part2(data) == 48


data = open('day3.in').read()
ans = part1(data)
print('part1:', ans)
ans = part2(data)
print('part2:', ans)
