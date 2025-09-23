#!/usr/bin/env julia

const Pos = Complex{Int}


function parsegrid(text)
    grid = Dict((x + im*y) => c
        for (y, s) in enumerate(split(text))
        for (x, c) in enumerate(s))
    return grid
end


function _combinations(itr)
    itr = collect(itr)
    ((a, b) for (i,a) in enumerate(itr) for b in itr[i+1:end])
end


function part1(data)
    grid = parsegrid(data)
    ans = Set{Pos}()
    for q in Set(values(grid))
        q == '.' && continue
        ps = [p for (p,v) in grid if v == q]
        for (a,b) in _combinations(ps)
            (2b - a) in keys(grid) && push!(ans, 2b - a)
            (2a - b) in keys(grid) && push!(ans, 2a - b)
        end
    end
    return length(ans)
end


function part2(data)
    grid = parsegrid(data)
    ans = Set{Pos}()
    for q in Set(values(grid))
        q == '.' && continue
        ps = [p for (p,v) in grid if v == q]
        for (a,b) in _combinations(ps)
            d = b - a
            for i in Iterators.countfrom(0, 1)
                (b + i * d) ∉ keys(grid) && break
                push!(ans, b + i * d)
            end
            for i in Iterators.countfrom(0, -1)
                (a + i * d) ∉ keys(grid) && break
                push!(ans, a + i * d)
            end
        end
    end
    return length(ans)
end


data = """
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
"""
@assert part1(data) == 14
@assert part2(data) == 34


data = readchomp("day8.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
