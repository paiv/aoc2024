#!/usr/bin/env python


def part1(data):
    data = data.strip().split('\n\n')
    locks = list()
    keys = list()

    for s in data:
        ls = s.strip().splitlines()
        xs = tuple(q.count('#') for q in zip(*ls))
        if ls[0] == '#####':
            locks.append(xs)
        else:
            keys.append(xs)

    ans = 0
    for p in locks:
        for q in keys:
            ans += all((x+y) < 8 for x,y in zip(p, q))
    return ans


data = '''
#####
.####
.####
.####
.#.#.
.#...
.....

#####
##.##
.#.##
...##
...#.
...#.
.....

.....
#....
#....
#...#
#.#.#
#.###
#####

.....
.....
#.#..
###..
###.#
###.#
#####

.....
.....
.....
#....
#.#..
#.#.#
#####
'''
assert part1(data) == 3


data = open('day25.in').read()
ans = part1(data)
print('part1:', ans)
