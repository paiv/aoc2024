#!/usr/bin/env julia


function parsedata(text)
    (parse.(Int, [m.match for m in eachmatch(r"\d+", s)])
        for s in split(text, "\n", keepempty=false))
end


function isvalid(ops, x, r)
    res = [x[begin]]
    for i in x[begin+1:end]
        res = [o(s, i) for s in res for o in ops]
    end
    return r in res
end


function part1(data)
    ans = 0
    for (r,x...) in parsedata(data)
        ans += r * isvalid([*,+], x, r)
    end
    return ans
end


function part2(data)
    c(x, y) = x * (10 ^ ndigits(y)) + y
    ans = 0
    for (r,x...) in parsedata(data)
        ans += r * isvalid([c,*,+], x, r)
    end
    return ans
end


data = """
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
"""
@assert part1(data) == 3749
@assert part2(data) == 11387


data = readchomp("day7.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
