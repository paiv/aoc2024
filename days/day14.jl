#!/usr/bin/env julia


function part1(data, M)
    data = [parse(Int, m.match) for m in eachmatch(r"-?\d+", data)]
    p = [data[1:4:end] data[2:4:end]]
    v = [data[3:4:end] data[4:4:end]]
    q = @. ((p + 100 * v) % M + M) % M
    w, h = M .÷ 2
    s = @. q[(q[:,1] != w) & (q[:,2] != h),:]
    t = @. (s ÷ [w h]) != 0
    prod(sum(all(t .== [i j]; dims=2)) for i in [0,1] for j in [0,1])
end


function part2(data, M)
    data = [parse(Int, m.match) for m in eachmatch(r"-?\d+", data)]
    p = [data[1:4:end] data[2:4:end]]
    v = [data[3:4:end] data[4:4:end]]
    w, h = M .÷ 2
    for t in 1:10^5
        q = @. ((p + t * v) % M + M) % M
        m = falses(M...)
        for (x,y) in eachrow(q)
            m[x+1, y+1] = true
        end
        if any(all(m[25:50,:], dims=1))
            return t
        end
    end
end


data = """
p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3
"""
@assert part1(data, [11 7]) == 12


data = readchomp("day14.in")
println("part1: ", part1(data, [101 103]))
println("part2: ", part2(data, [101 103]))
