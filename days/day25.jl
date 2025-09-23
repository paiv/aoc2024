#!/usr/bin/env julia


function parsedata(text)
    ks = [stack(split(s), dims=1) .== '#'
        for s in split(text, "\n\n", keepempty=false)]
    locks = [sum(k, dims=1) .- 1 for k in ks if k[1,1]]
    lkeys = [sum(k, dims=1) .- 1 for k in ks if !k[1,1]]
    return (locks, lkeys)
end


function _isfit(lock, key)
    all(@. lock + key < 6)
end


function part1(data)
    locks, lkeys = parsedata(data)
    sum(_isfit(l,k) for l in locks, k in lkeys)
end


data = """
#####
.####
.####
.####
.#.#.
.#...
.....

#####
##.##
.#.##
...##
...#.
...#.
.....

.....
#....
#....
#...#
#.#.#
#.###
#####

.....
.....
#.#..
###..
###.#
###.#
#####

.....
.....
.....
#....
#.#..
#.#.#
#####
"""
@assert part1(data) == 3


data = readchomp("day25.in")
println("part1: ", part1(data))
