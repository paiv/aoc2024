#!/usr/bin/env julia


const Pos = CartesianIndex{2}


function parsegrid(text)
    grid = stack(split(text))
    start = findfirst(==('S'), grid)
    goal = findfirst(==('E'), grid)
    grid[[start, goal]] .= '.'
    return (grid, start, goal)
end


function _allpaths(grid, start)
    neibs = Pos.([(0,1), (0,-1), (1,0), (-1,0)])
    fringe = [(0, start)]
    seen = Dict{Pos,Int}()
    while !isempty(fringe)
        wei, pos = popfirst!(fringe)
        (pos in keys(seen)) && continue
        seen[pos] = wei
        for q in pos .+ neibs
            if get(grid, q, '?') == '.'
                push!(fringe, (wei + 1, q))
            end
        end
    end
    return seen
end


function _rombus(side)
    [Pos(y,x)
        for v in 1:side for x in -v:v
        for y in (abs(x) == v ? [0] : [v - abs(x), -v + abs(x)])]
end


function solve(data, N, T)
    grid, start, goal = parsegrid(data)
    rombus = _rombus(T)
    fromstart = _allpaths(grid, start)
    togoal = _allpaths(grid, goal)
    base = fromstart[goal]
    ans = 0
    for (pos, wei) in fromstart
        for d in rombus
            w = get(togoal, pos + d, nothing)
            if w != nothing
                v = sum(abs.(d.I))
                ans += (wei + v + w + N) <= base
            end
        end
    end
    return ans
end


part1(data, N) = solve(data, N, 2)
part2(data, N) = solve(data, N, 20)


data = """
###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############
"""
@assert part1(data, 12) == 8
@assert part2(data, 72) == 29


data = readchomp("day20.in")
println("part1: ", part1(data, 100))
println("part2: ", part2(data, 100))
