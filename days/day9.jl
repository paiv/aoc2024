#!/usr/bin/env julia


const Block = Tuple{Int, Int}
const FileBlock = Tuple{Int, Int, Int}


function parsedisk(text)
    files = Vector{FileBlock}()
    space = Vector{Block}()
    state = 0
    fileid = 0
    i = 0
    for n in parse.(Int, collect(chomp(data)))
        if state == 0
            n > 0 && push!(files, (i, n, fileid))
            fileid += 1
        else
            n > 0 && push!(space, (i, n))
        end
        i += n
        state = 1 - state
    end
    return (files, space)
end


function _defrag!(disk)
    files, space = disk
    for k in reverse(1:length(files))
        (j, n, x) = files[k]
        for (q, (i, m)) in enumerate(space)
            j <= i && break
            if m >= n
                files[k] = (i, n, x)
                space[q] = (i + n, m - n)
                break
            end
        end
    end
end


function _checksum(disk)
    files, _ = disk
    return sum(x * (n * i + (n - 1) * n ÷ 2)
        for (i, n, x) in files)
end


function _flatten(disk)
    files, space = disk
    space = [(i+j-1, 1) for (i,n) in space for j in 1:n]
    files = [(i+j-1, 1, x) for (i,n,x) in files for j in 1:n]
    return (files, space)
end


function part1(data)
    disk = _flatten(parsedisk(data))
    _defrag!(disk)
    ans = _checksum(disk)
    return ans
end


function part2(data)
    disk = parsedisk(data)
    _defrag!(disk)
    ans = _checksum(disk)
    return ans
end


data = """
2333133121414131402
"""
@assert part1(data) == 1928
@assert part2(data) == 2858


data = readchomp("day9.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
