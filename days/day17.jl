#!/usr/bin/env julia


function _disasm(img)
    a,b,c,prog... = img
    println("A=$(a) B=$(b) C=$(c)")
    println("prog=", prog)
    _sarg = "0123ABC"
    pc = 0
    while pc + 2 <= length(prog)
        op, larg = prog[pc+1:pc+2]
        sarg = _sarg[larg + 1]
        pc += 2
        if op == 0
            println("$(pc-2): adv $(sarg)")
        elseif op == 1
            println("$(pc-2): bxl $(larg)")
        elseif op == 2
            println("$(pc-2): bst $(sarg)")
        elseif op == 3
            println("$(pc-2): jnz $(larg)")
        elseif op == 4
            println("$(pc-2): bxc")
        elseif op == 5
            println("$(pc-2): out $(sarg)")
        elseif op == 6
            println("$(pc-2): bdv $(sarg)")
        elseif op == 7
            println("$(pc-2): cdv $(sarg)")
        else
            println("$(pc-2): $(op) $(arg)")
            throw(error("unhandled opcode $(op)"))
        end
    end
end


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
            b ⊻= larg
        elseif op == 2
            b = carg % 8
        elseif op == 3
            (a != 0) && (pc = larg)
        elseif op == 4
            b ⊻= c
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
    out = empty(prog)
    a = 1
    while true
        img[1] = a
        out = _run(img)
        out == prog && return a
        if out == prog[end-length(out)+1:end]
            a *= 8
        else
            a += 1
        end
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
#@assert part2(data) == 117440


data = readchomp("day17.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
