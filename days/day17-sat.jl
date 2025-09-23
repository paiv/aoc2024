#!/usr/bin/env julia
#import Pkg; Pkg.add("Satisfiability")
using Satisfiability


function _arg(regs, arg)
    if arg in 0:3
        arg
    elseif arg in 4:6
        regs[arg - 3]
    end
end


function _run(img)
    a,b,c,prog... = img
    pc = 0
    out = Int[]
    while pc + 2 <= length(prog)
        op, larg = prog[pc+1:pc+2]
        carg = _arg([a,b,c], larg)
        pc += 2
        if op == 0
            a ÷= 2^carg
        elseif op == 1
            b = xor(b, larg)
        elseif op == 2
            b = carg % 8
        elseif op == 3
            (a != 0) && (pc = larg)
        elseif op == 4
            b = xor(b, c)
        elseif op == 5
            push!(out, carg % 8)
        elseif op == 6
            b = a ÷ 2^carg
        elseif op == 7
            c = a ÷ 2^carg
        else
            throw(error("unhandled opcode $(op)"))
        end
    end
    img[1:3] = [a, b, c]
    return out
end


function part1(data)
    img = [parse(Int, m.match) for m in eachmatch(r"\d+", data)]
    out = _run(img)
    ans = join(out, ",")
    return ans
end


function part2(data)
    img = [parse(Int, m.match) for m in eachmatch(r"\d+", data)]
    prog = img[4:end]
    expr = []
    w = length(prog) * 3
    @satvariable(s, BitVector, w)
    ra = s
    rb = 0
    rc = 0
    for x in prog
        for pc in 1:2:length(prog)
            regs = [0, 1, 2, 3, ra, rb, rc]
            op, larg = prog[pc:pc+1]
            carg = regs[larg + 1]
            larg = bvconst(larg, w)
            if op == 0
                ra = ra >>> carg
            elseif op == 1
                #rb = xor(rb, larg)
                rb = (rb & ~larg) | (~rb & larg)
            elseif op == 2
                rb = urem(carg, 8)
            elseif op == 3
                #
            elseif op == 4
                #rb = xor(rb, rc)
                rb = (rb & ~rc) | (~rb & rc)
            elseif op == 5
                push!(expr, urem(carg, 8) == x)
            elseif op == 6
                rb = ra >>> carg
            elseif op == 7
                rc = ra >>> carg
            end
        end
    end
    res = sat!(expr...)
    if res == :SAT
        ans = Int(value(s))
        img[1] = ans
        out = _run(img)
        @assert out == prog
        return ans
    end
end


data = """
Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0
"""
@assert part1(data) == "4,6,3,5,6,3,5,2,1,0"


data = """
Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0
"""
@assert part2(data) == 117440


data = readchomp("day17.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
