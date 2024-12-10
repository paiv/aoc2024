#!/usr/bin/env python


def part1(data):
    xs = list(map(int, data.strip()))
    disk = list()
    i = 0
    for x,s in zip(xs[::2], xs[1::2]):
        disk.extend([i] * x)
        disk.extend([None] * s)
        i += 1
    if len(xs) % 2:
        disk.extend([i] * xs[-1])
    r = len(disk) - 1
    l = disk.index(None)
    while l < r:
        x = disk[r]
        if x is not None:
            disk[l] = x
            disk[r] = None
            l = disk.index(None, l+1)
        r -= 1
    ans = sum(i*(x or 0) for i,x in enumerate(disk))
    return ans


def part2(data):
    xs = list(map(int, data.strip()))
    frag = xs[::2]
    free = xs[1::2]
    disk = [list() for _ in range(len(xs))]

    for i in range(len(frag))[::-1]:
        n = frag[i]
        for j in range(i):
            if n <= free[j]:
                free[j] -= n
                free[i-1] += n
                disk[1+j*2].append(i)
                break
        else:
            disk[i*2].append(i)

    ans = 0
    i = 0
    for j,ps in enumerate(disk):
        for x in ps:
            for _ in range(frag[x]):
                ans += i * x
                i += 1
        if j % 2:
            i += free[j//2]
    return ans


data = '''
2333133121414131402
'''
assert part1(data) == 1928
assert part2(data) == 2858


data = open('day9.in').read()
ans = part1(data)
print('part1:', ans)
ans = part2(data)
print('part2:', ans)
