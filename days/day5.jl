#!/usr/bin/env julia


function parsedata(data)
    sr, sp = split(data, "\n\n")
    rules = Set(Tuple(parse.(Int, split(s, "|"))) for s in split(sr))
    updates = [parse.(Int, split(s, ",")) for s in split(sp)]
    return rules, updates
end


function part1(data)
    rules, updates = parsedata(data)
    isvalid(update) = all((y, x) ∉ rules
        for (i,x) in enumerate(update) for y in update[i+1:end])
    valid = filter(isvalid, updates)
    ans = sum(v[begin + length(v) ÷ 2] for v in valid)
    return ans
end


function part2(data)
    rules, updates = parsedata(data)
    isvalid(update) = all((y, x) ∉ rules
        for (i,x) in enumerate(update) for y in update[i+1:end])
    invalid = filter(!isvalid, updates)
    isrule(x, y) = (x,y) ∈ rules
    valid = sort.(invalid, lt=isrule)
    ans = sum(v[begin + length(v) ÷ 2] for v in valid)
    return ans
end


data = """
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
"""
@assert part1(data) == 143
@assert part2(data) == 123


data = readchomp("day5.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
