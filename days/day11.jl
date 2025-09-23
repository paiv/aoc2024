#!/usr/bin/env julia


function blink(x::Int)
    if x == 0
        [1]
    elseif iseven(ndigits(x))
        divrem(x, 10 ^ (ndigits(x) ÷ 2))
    else
        [x * 2024]
    end
end


function solve(data, N)
    data = parse.(Int, split(data))
    stones = Dict(x=>1 for x in data)
    for _ in 1:N
        state = Dict{Int,Int}()
        for (x, n) in stones, s in blink(x)
            state[s] = get(state, s, 0) + n
        end
        stones = state
    end
    return sum(values(stones))
end


part1(data) = solve(data, 25)
part2(data) = solve(data, 75)


data = """
125 17
"""
@assert part1(data) == 55312


data = readchomp("day11.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
