#!/usr/bin/env python
from collections import defaultdict


def part1(data):
    rules, jobs = data.split('\n\n')
    rules = [tuple(map(int, s.split('|'))) for s in rules.split()]
    jobs = [list(map(int, s.split(','))) for s in jobs.split()]

    drul = defaultdict(list)
    for x,y in rules:
        drul[x].append(y)

    def valid(xs):
        for i,x in enumerate(xs):
            if (ps := drul.get(x)):
                for p in ps:
                    if p in xs[:i]:
                        return False
        return xs[len(xs) // 2]

    ans = sum(map(valid, jobs))
    return ans


def part2(data):
    rules, jobs = data.split('\n\n')
    rules = [tuple(map(int, s.split('|'))) for s in rules.split()]
    jobs = [list(map(int, s.split(','))) for s in jobs.split()]

    drul = defaultdict(list)
    for x,y in rules:
        drul[x].append(y)

    def invalid(xs):
        for i,x in enumerate(xs):
            if (ps := drul.get(x)):
                for p in ps:
                    if p in xs[:i]:
                        return True

    def valid(xs):
        s = set(xs)
        res = list()
        for x in xs:
            if (ps := drul.get(x)):
                i = len(res)
                for p in ps:
                    if p in res:
                        i = min(i, res.index(p))
                res.insert(i, x)
                s.remove(x)
        res.extend(s)
        return res[len(res) // 2]

    ans = sum(map(valid, filter(invalid, jobs)))
    return ans


data = '''
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
'''
assert part1(data) == 143
assert part2(data) == 123


data = open('day5.in').read()
ans = part1(data)
print('part1:', ans)
ans = part2(data)
print('part2:', ans)
