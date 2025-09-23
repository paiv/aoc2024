#!/usr/bin/env julia


function part1(data)
    g = (parse.(Int, m.captures)
        for m in eachmatch(r"mul\((\d+),(\d+)\)", data))
    ans = prod.(g) |> sum
    return ans
end


function part2(data)
    ans = 0
    state = 1
    for m in eachmatch(r"do\(\)|don't\(\)|mul\((\d+),(\d+)\)", data)
        if startswith(m.match, "don't")
            state = 0
        elseif startswith(m.match, "do")
            state = 1
        else
            n = parse.(Int, m.captures) |> prod
            ans += state * n
        end
    end
    return ans
end


data = """
xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
"""
@assert part1(data) == 161

data = """
xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
"""
@assert part2(data) == 48


data = readchomp("day3.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
