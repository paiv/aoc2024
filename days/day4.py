#!/usr/bin/env python

def part1(data):
    lines = data.strip().splitlines()
    ans = 0
    for s in lines:
        ans += s.count('XMAS')
        ans += s.count('SAMX')
    for s in zip(*lines):
        s = ''.join(s)
        ans += s.count('XMAS')
        ans += s.count('SAMX')
    for i,s in enumerate(lines[:-3]):
        for j,c in enumerate(s[:-3]):
            r,q,v = lines[i+1:i+4]
            if c in 'XS':
                a = c + r[j+1] + q[j+2] + v[j+3]
                ans += a in ('XMAS', 'SAMX')
            if (c := s[j+3]) in 'XS':
                a = c + r[j+2] + q[j+1] + v[j]
                ans += a in ('XMAS', 'SAMX')
    return ans


def part2(data):
    lines = data.strip().splitlines()
    ans = 0
    for i,s in enumerate(lines[:-2]):
        for j,c in enumerate(s[:-2]):
            p = s[j+2]
            if c in 'MS' and p in 'MS':
                r,q = lines[i+1:i+3]
                a = c + r[j+1] + q[j+2]
                b = p + r[j+1] + q[j]
                ans += a in ('MAS', 'SAM') and b in ('MAS', 'SAM')
    return ans


data = '''
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
'''
assert part1(data) == 18
assert part2(data) == 9


data = open('day4.in').read()
ans = part1(data)
print('part1:', ans)
ans = part2(data)
print('part2:', ans)
