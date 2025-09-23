#!/usr/bin/env julia


const Pos = Complex{Int}


function _pgrid1(text)
    Dict((x + im * y) => c
        for (y, s) in enumerate(split(text))
        for (x, c) in enumerate(s))
end


function _pgrid2(text)
    dd = Dict('@' => ('@','.'), 'O' => ('[',']'))
    Dict((2x-2+i + im * y) => get(dd, c, (c,c))[i]
        for (y, s) in enumerate(split(text))
        for (x, c) in enumerate(s)
        for i in 1:2)
end


function parsedata(text, pgrid)
    a, b = split(text, "\n\n", keepempty=false)
    grid = pgrid(a)
    dirs = Dict('<'=>-1, '>'=>1, '^'=>-im, 'v'=>im)
    moves = [dirs[c] for s in split(b) for c in s]
    start = findfirst(==('@'), grid)
    grid[start] = '.'
    return (grid, start, moves)
end


function _canmove(grid, pos, dir)
    if imag(dir) == 0
        while true
            pos += dir
            c = get(grid, pos, '#')
            c == '.' && return true
            c == '#' && return false
        end
    else
        fringe = [pos]
        while true
            wave = empty(fringe)
            allspace = true
            for p in fringe .+ dir
                c = get(grid, p, '#')
                c == '#' && return false
                if c == 'O'
                    allspace = false
                    push!(wave, p)
                elseif c == '['
                    allspace = false
                    push!(wave, p)
                    push!(wave, p + 1)
                elseif c == ']'
                    allspace = false
                    push!(wave, p - 1)
                    push!(wave, p)
                end
            end
            allspace && return true
            fringe = wave
        end
    end
end


function _hmov(grid, start, dir)
    pos = start
    while true
        pos += dir
        get(grid, pos, '#') == '.' && break
    end
    while pos != start
        grid[pos] = grid[pos - dir]
        pos -= dir
    end
end


function _vmov(grid, start, dir)
    waves = [Set([start+dir])]
    while true
        wave = Set{Pos}()
        allspace = true
        for p in waves[end] .+ dir
            c = get(grid, p - dir, '#')
            if c != '.'
                allspace = false
                push!(wave, p)
                if c == '['
                    push!(wave, p + 1)
                elseif c == ']'
                    push!(wave, p - 1)
                end
            end
        end
        allspace && break
        push!(waves, wave)
    end
    for wave in reverse(waves)
        for p in wave
            grid[p] = grid[p - dir]
            grid[p - dir] = '.'
        end
    end
end


function _domove(grid, start, dir)
    f = imag(dir) == 0 ? _hmov : _vmov
    f(grid, start, dir)
    return (start + dir)
end


function _display(grid, pos)
    for y in Iterators.countfrom()
        for x in Iterators.countfrom()
            p = x + im * y
            c = get(grid, p, '?')
            c == '?' && x == 1 && return
            c == '?' && break
            c = p == pos ? '@' : c
            print(c)
        end
        println()
    end
end


function solve(data, C, pgrid)
    grid, pos, moves = parsedata(data, pgrid)
    for d in moves
        if _canmove(grid, pos, d)
            pos = _domove(grid, pos, d)
        end
    end
    ans = sum(p->100 * imag(p) + real(p), findall(==(C), grid) .- (1+im))
    return ans
end


part1(data) = solve(data, 'O', _pgrid1)
part2(data) = solve(data, '[', _pgrid2)


data = """
########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

<^^>>>vv<v>>v<<
"""
@assert part1(data) == 2028


data = """
#######
#...#.#
#.....#
#..OO@#
#..O..#
#.....#
#######

<vv<<^^<<^^
"""
@assert part2(data) == 618


data = """
##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
"""
@assert part1(data) == 10092
@assert part2(data) == 9021


data = readchomp("day15.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
