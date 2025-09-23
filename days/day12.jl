#!/usr/bin/env julia


const Pos = CartesianIndex{2}
const _Neibs = Pos.([(0,1), (0,-1), (1,0), (-1,0)])


function _segment(grid)
    res = Vector{Pos}[]
    seen = Set{Pos}()
    for p in keys(grid)
        p in seen && continue
        region = [p]
        for p in region, u in p .+ _Neibs
            if get(grid, u, '?') == grid[p] && u ∉ region
                push!(region, u)
            end
        end
        union!(seen, region)
        push!(res, region)
    end
    return res
end


function _fence(region)
    perimeter = sum(region) do p
        sum(∉(region), _Neibs .+ p)
    end
    return length(region) * perimeter
end


function _fence2(region)
    sides = Tuple{Int,Int,Int}[]
    for p in sort(region), (j, d) in enumerate(_Neibs)
        (p+d) in region && continue
        y, x = first(d.I) != 0 ? (p+d).I : reverse((p+d).I)
        filter!(!=((j, y, x-1)), sides)
        push!(sides, (j, y, x))
    end
    res = length(region) * length(sides)
    return res
end


function part1(data)
    grid = stack(split(data))
    ans = sum(_fence, _segment(grid))
    return ans
end


function part2(data)
    grid = stack(split(data))
    ans = sum(_fence2, _segment(grid))
    return ans
end


data = """
AAAA
BBCD
BBCC
EEEC
"""
@assert part1(data) == 140
@assert part2(data) == 80


data = """
RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
"""
@assert part1(data) == 1930
@assert part2(data) == 1206


data = """
HHHHHHH
HoooooH
HoHHHoH
HoHoHoH
HHHoHHH
"""
@assert part1(data) == 1344
@assert part2(data) == 464


data = readchomp("day12.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
