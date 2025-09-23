#!/usr/bin/env julia


function parsegrid(text)
    grid = Dict((x + im*y)=>c
        for (y, s) in enumerate(split(text))
        for (x, c) in enumerate(s))
    start, = [p for (p,c) in grid if c == '^']
    return (grid, start)
end


function part1(data)
    grid, start = parsegrid(data)
    pos, dir = start, -im
    seen = Set([pos])
    while true
        c = get(grid, pos + dir, '?')
        c == '?' && break
        if c == '#'
            dir *= im
        else
            pos += dir
            push!(seen, pos)
        end
    end
    return length(seen)
end


function _probe(grid, pos, dir)
    seen = Set([(pos, dir)])
    while true
        c = get(grid, pos + dir, '?')
        c == '?' && return false
        if c == '#'
            dir *= im
        else
            pos += dir
        end
        k = (pos, dir)
        k in seen && return true
        push!(seen, k)
    end
end


function part2(data)
    grid, start = parsegrid(data)
    pos, dir = start, -im
    seen = Set([pos])
    ans = 0
    while true
        c = get(grid, pos + dir, '?')
        c == '?' && break
        if c == '#'
            dir *= im
        else
            pos += dir
            if pos ∉ seen
                push!(seen, pos)
                t = merge(grid, Dict(pos=>'#'))
                ans += _probe(t, pos - dir, dir)
            end
        end
    end
    return ans
end


data = """
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
"""
@assert part1(data) == 41
@assert part2(data) == 6


data = readchomp("day6.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
