#!/usr/bin/env julia


function solve(data, N)
    data = [parse(Int, m.match) for m in eachmatch(r"[+-]?\d+", data)]
    ans = 0
    for i in 1:6:length(data)
        a = [data[i+0:i+1] data[i+2:i+3]]
        b = data[i+4:i+5] .+ N
        x = round.(a \ b; digits=4)
        if all(isinteger.(x))
            ans += sum(Int.(x) .* [3, 1])
        end
    end
    return ans
end


part1(data) = solve(data, 0)
part2(data) = solve(data, 10000000000000)


data = """
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
"""
@assert part1(data) == 480


data = readchomp("day13.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
