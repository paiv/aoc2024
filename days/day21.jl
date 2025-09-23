#!/usr/bin/env julia


const Pos = CartesianIndex{2}


function _allpaths(grid)
    paths = Dict{Tuple{Pos,Pos},String}()
    for start in keys(grid)
        for goal in keys(grid)
            d = goal - start
            v = (d[1] < 0 ? '^' : 'v') ^ abs(d[1])
            h = (d[2] < 0 ? '<' : '>') ^ abs(d[2])
            paths[(start, goal)] = v * h
            if grid[goal[1], start[2]] == '#' ||
                (d[2] < 0 && grid[start[1], goal[2]] != '#')
                paths[(start, goal)] = h * v
            end
        end
    end
    return paths
end


function parsegrid(text)
    grid = stack(split(text), dims=1)
    start = findfirst(==('A'), grid)
    return (grid, start)
end


function _encodepath(grid, paths, pos, path, n)
    res = Dict{String,Int}()
    for c in path
        to = findfirst(==(c), grid)
        s = paths[(pos, to)] * 'A'
        res[s] = get(res, s, 0) + n
        pos = to
    end
    return res
end


function _encodepath(grid, paths, pos, path)
    res = Dict{String,Int}()
    for (s, n) in path
        t = _encodepath(grid, paths, pos, s, n)
        mergewith!(+, res, t)
    end
    return res
end


function solve(data, N)
    snpd =
    """
    789
    456
    123
    #0A
    """
    sdpd =
    """
    #^A
    <v>
    """
    numpad, numA = parsegrid(snpd)
    dpad, dirA = parsegrid(sdpd)
    npaths = _allpaths(numpad)
    dpaths = _allpaths(dpad)
    ans = 0
    for code in split(data)
        s = _encodepath(numpad, npaths, numA, Dict(code=>1))
        for _ in 1:N
            s = _encodepath(dpad, dpaths, dirA, s)
        end
        ans += sum(length(k)*n for (k,n) in s) * parse(Int, code[1:end-1])
    end
    return ans
end


part1(data) = solve(data, 2)
part2(data) = solve(data, 25)


data = """
029A
980A
179A
456A
379A
"""
@assert part1(data) == 126384


data = readchomp("day21.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
