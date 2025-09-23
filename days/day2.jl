#!/usr/bin/env julia


function issafe(ar::AbstractVector)
    s = Set(diff(ar))
    return (s ⊆ [1, 2, 3]) || (s ⊆ [-1, -2, -3])
end


function part1(data)
    ans = 0
    for line in split(data, "\n", keepempty=false)
        xs = parse.(Int, split(line))
        ans += issafe(xs)
    end
    return ans
end


function part2(data)
    ans = 0
    for line in split(data, "\n", keepempty=false)
        xs = parse.(Int, split(line))
        for i in range(0, length(xs))
            if issafe([xs[1:i]; xs[i+2:end]])
                ans += 1
                break
            end
        end
    end
    return ans
end


data = """
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"""

@assert part1(data) == 2
@assert part2(data) == 4


data = readchomp("day2.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
