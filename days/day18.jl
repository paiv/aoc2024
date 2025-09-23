#!usr/bin/env julia


const Pos = CartesianIndex{2}


function _display(grid, pois)
    for x in axes(grid, 2)
        for y in axes(grid, 1)
            p = Pos(y, x)
            c = p in pois ? 'O' : grid[p] ? '.' : '#'
            print(c)
        end
        println()
    end
end


function _findpath(grid, start, goal)
    neibs = Pos.([(0,1), (0,-1), (1,0), (-1,0)])
    fringe = [(0, start)]
    seen = Set{Pos}()
    while !isempty(fringe)
        wei, pos = popfirst!(fringe)
        pos == goal && return wei
        pos in seen && continue
        push!(seen, pos)
        for d in neibs
            if get(grid, pos + d, false)
                push!(fringe, (wei + 1, pos + d))
            end
        end
    end
end


function parsedata(text)
    [Pos(parse.(Int, p)...) + Pos(1,1)
        for m in eachmatch(r"\d+,\d+", data)
        for p in [split(m.match, ",")]]
end


function part1(data, N, T)
    data = parsedata(data)
    grid = trues(N, N)
    start, goal = Pos(1,1), Pos(N, N)
    grid[data[1:T]] .= false
    return _findpath(grid, start, goal)
end


function part2(data, N, T)
    data = parsedata(data)
    grid = trues(N, N)
    start, goal = Pos(1,1), Pos(N, N)
    grid[data[1:T]] .= false
    for i in (T+1):length(data)
        pos = data[i]
        grid[pos] = false
        res = _findpath(grid, start, goal)
        if isnothing(res)
            x,y = (pos - Pos(1,1)).I
            return "$(x),$(y)"
        end
    end
end


data = """
5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0
"""
@assert part1(data, 7, 12) == 22
@assert part2(data, 7, 12) == "6,1"


data = readchomp("day18.in")
println("part1: ", part1(data, 71, 1024))
println("part2: ", part2(data, 71, 1024))
