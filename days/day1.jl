#!/usr/bin/env julia


function part1(data)
    xs = parse.(Int, split(data))
    ans = sum(abs, sort(xs[1:2:end]) - sort(xs[2:2:end]))
    return ans
end


function part2(data)
    xs = parse.(Int, split(data))
    n = [count(==(x), xs[2:2:end]) for x in xs[1:2:end]]
    ans = xs[1:2:end]' * n
    return ans
end


data = """
3   4
4   3
2   5
1   3
3   9
3   3
"""
@assert part1(data) == 11
@assert part2(data) == 31


data = readchomp("day1.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
