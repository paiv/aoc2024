#!/usr/bin/env julia


function _mp(a::Int, b::Int)
    (a ⊻ b) % 16777216
end


function _secret(x::Int)
    x = _mp(x, x << 6)
    x = _mp(x, x >> 5)
    x = _mp(x, x << 11)
    return x
end


function _secrets(N::Int, x::Int)
    reduce(1:N, init=[x]) do x,_
        push!(x, _secret(x[end]))
    end
end


function part1(data)
    data = parse.(Int, split(data))
    ans = sum(_secrets(2000, x)[end] for x in data)
    return ans
end


function part2(data)
    data = parse.(Int, split(data))
    prices = [_secrets(2000, x) for x in data]
    diffs = [diff(x .% 10) for x in prices]
    stats = Dict{Vector{Int},Int}()
    for (i, bs) in enumerate(diffs)
        seen = Set{Vector{Int}}()
        for j in 1:length(bs)-3
            w = bs[j:j+3]
            w in seen && continue
            push!(seen, w)
            stats[w] = get(stats, w, 0) + prices[i][j+4] % 10
        end
    end
    ans = maximum(values(stats))
    return ans
end


data = """
1
10
100
2024
"""
@assert part1(data) == 37327623


data = """
1
2
3
2024
"""
@assert part2(data) == 23


data = readchomp("day22.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
