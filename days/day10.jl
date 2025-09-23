#!/usr/bin/env julia


function part1(data)
    grid = parse.(Int8, stack(split(data)))
    ix9 = findall(==(9), grid)
    m = falses(size(grid)..., length(ix9))
    for (i,x) in enumerate(ix9)
        m[x, i] = true
    end
    for k in 8:-1:0
        for q in findall(==(k), grid)
            for d in [(0,1), (0,-1), (1,0), (-1,0)]
                u = q + CartesianIndex(d)
                if get(grid, u, 10) == k + 1
                    m[q,:] .|= m[u,:]
                end
            end
        end
    end
    ans = sum(m[grid .== 0, :])
    return ans
end


function part2(data)
    grid = parse.(Int8, stack(split(data)))
    m = zeros(Int, size(grid))
    m[grid .== 9] .= 1
    for k in 8:-1:0
        for q in findall(==(k), grid)
            for d in [(0,1), (0,-1), (1,0), (-1,0)]
                u = q + CartesianIndex(d)
                if get(grid, u, 10) == k + 1
                    m[q] += m[u]
                end
            end
        end
    end
    ans = sum(m[grid .== 0])
    return ans
end


data = """
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
"""
@assert part1(data) == 36
@assert part2(data) == 81


data = readchomp("day10.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
