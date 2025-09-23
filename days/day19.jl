#!/usr/bin/env julia


function parsedata(text)
    abc, words = split(text, "\n\n", keepempty=false)
    (split(abc, r", *"), split(words))
end


function _isvalid(abc, word, memo)
    isempty(word) && return 1
    t = get(memo, word, nothing)
    (t != nothing) && return t
    n = 0
    for c in abc
        if startswith(word, c)
            n += _isvalid(abc, word[length(c)+1:end], memo)
        end
    end
    memo[word] = n
    return n
end


function _isvalid(abc, word)
    _isvalid(abc, word, Dict{SubString,Int}())
end


function part1(data)
    abc, words = parsedata(data)
    ans = sum(_isvalid(abc, w) != 0 for w in words)
    return ans
end


function part2(data)
    abc, words = parsedata(data)
    ans = sum(_isvalid(abc, w) for w in words)
    return ans
end


data = """
r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb
"""
@assert part1(data) == 6
@assert part2(data) == 16


data = readchomp("day19.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
