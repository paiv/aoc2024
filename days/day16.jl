#!/usr/bin/env julia


const Pos = Complex{Int}


function parsegrid(text)
    grid = Dict((x + im * y) => c
        for (y, s) in enumerate(split(text))
        for (x, c) in enumerate(s)
        if c != '#')
    start = findfirst(==('S'), grid)
    goal = findfirst(==('E'), grid)
    return (Set(keys(grid)), start, goal)
end


function part1(data)
    grid, start, goal = parsegrid(data)
    fringe = [(0, start, complex(1))]
    seen = Set{Tuple{Pos,Pos}}()
    while !isempty(fringe)
        wei, pos, dir = popfirst!(fringe)
        pos == goal && return wei
        k = (pos, dir)
        k in seen && continue
        push!(seen, k)
        (pos + dir) in grid &&
            push!(fringe, (wei + 1, pos + dir, dir))
        (pos + dir * im) in grid &&
            push!(fringe, (wei + 1001, pos + dir * im, dir * im))
        (pos + dir * -im) in grid &&
            push!(fringe, (wei + 1001, pos + dir * -im, dir * -im))
        sort!(fringe, by=p->p[1])
    end
end


function _display(grid, path)
    w = maximum(real.(grid)) + 1
    h = maximum(imag.(grid)) + 1
    for y in 1:h
        for x in 1:w
            p = x + im * y
            c = p in path ? 'O' : p in grid ? '.' : '#'
            print(c)
        end
        println()
    end
end


function part2(data)
    grid, start, goal = parsegrid(data)
    startdir = complex(1)

    best = typemax(Int)
    paths = [(0, (start, startdir))]
    terms = Int[]
    fringe = [(0, 1)]
    seen = Dict{Tuple{Pos,Pos},Int}()

    while !isempty(fringe)
        wei, ip = popfirst!(fringe)
        wei > best && continue
        _, (pos, dir) = paths[ip]
        if pos == goal
            if wei < best
                best = wei
                empty!(terms)
            end
            push!(terms, ip)
            continue
        end
        get(seen, (pos, dir), typemax(Int)) < wei && continue
        seen[(pos, dir)] = wei
        if (pos + dir) in grid
            push!(paths, (ip, (pos + dir, dir)))
            push!(fringe, (wei + 1, length(paths)))
        end
        for i in [im, -im]
            if (pos + dir * i) in grid
                push!(paths, (ip, (pos + dir * i, dir * i)))
                push!(fringe, (wei + 1001, length(paths)))
            end
        end
    end

    ans = Set{Pos}()
    for ip in terms
        while ip != 0
            prev, (pos, _) = paths[ip]
            push!(ans, pos)
            ip = prev
        end
    end
    return length(ans)
end


data = """
###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############
"""
@assert part1(data) == 7036
@assert part2(data) == 45


data = """
#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################
"""
@assert part1(data) == 11048
@assert part2(data) == 64


data = readchomp("day16.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
