#!/usr/bin/env julia


function part1(data)
    grid = Dict((x+im*y)=>c
        for (y,s) in enumerate(collect.(split(data)))
        for (x,c) in enumerate(s))
    vs = [[0, 1, 2, 3],
        [0, 1im, 2im, 3im],
        [0, 1+1im, 2+2im, 3+3im],
        [0, 1-1im, 2-2im, 3-3im]]
    vs = [vs; reverse.(vs)]
    isxmas(v, k) = [get(grid, k+x, '?') for x in v] == ['X','M','A','S']
    ans = sum(isxmas(v, k) for k in keys(grid), v in vs)
    return ans
end


function part2(data)
    grid = Dict((x+im*y)=>c
        for (y,s) in enumerate(collect.(split(data)))
        for (x,c) in enumerate(s))
    vs = [[-1-1im, 0, 1+1im, -1+1im, 0, 1-1im],
        [-1-1im, 0, 1+1im, 1-1im, 0, -1+1im],]
    vs = [vs; reverse.(vs)]
    isxmas(v, k) = [get(grid, k+x, '?') for x in v] == ['M','A','S','M','A','S']
    ans = sum(isxmas(v, k) for k in keys(grid), v in vs)
    return ans
end


data = """
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"""
@assert part1(data) == 18
@assert part2(data) == 9


data = readchomp("day4.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
