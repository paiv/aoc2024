#!/usr/bin/env julia


function parsegrid(text)
    input = Dict(m[1] => parse(Bool, m[2])
        for m in eachmatch(r"(\S+): *(\d+)", text))
    ops = Dict("AND"=>(&), "OR"=>(|), "XOR"=>(⊻))
    grid = Dict(m[4] => (ops[m[2]], m[1], m[3])
        for m in eachmatch(r"(\S+) +(AND|OR|XOR) +(\S+) *-> *(\S+)", text))
    nets = Dict{AbstractString,Vector{AbstractString}}()
    for (z,(_,x,y)) in grid
        nets[x] = push!(get(nets, x, []), z)
        nets[y] = push!(get(nets, y, []), z)
    end
    wires = Dict(n=>get(input, n, false)
        for (z,(_,x,y)) in grid for n in [x,y,z])
    return (grid, nets, wires)
end


function _display(grid)
    gates = collect(grid)
    ops = Dict((&)=>"and", (|)=>"or", (⊻)=>"xor")
    names = ["""_$i [label = "$(ops[op])", color="#405081" fontcolor="#cfdbff"]"""
        for (i,(z,(op,x,y))) in enumerate(gates)]
    wires = [
        ["_$i -> $z" for (i,(z,(op,x,y))) in enumerate(gates)]
        ["$w -> _$i" for (i,(z,(op,x,y))) in enumerate(gates) for w in [x,y]]
        ]
    nodes = join(names, '\n')
    edges = join(wires, '\n')
    println("""
    digraph {
    bgcolor = "#202124"
    node [color = "#5F626B", fontcolor = "#f1f3f4"]
    edge [color = "#5F626B"]
    $nodes
    $edges
    }
    """)
end


function _tick(grid, wires)
    changed = false
    for (z, (op, x, y)) in grid
        t = op(wires[x], wires[y])
        changed |= t != wires[z]
        wires[z] = t
    end
    return changed
end


function _powerup(grid, wires)
    while true
        _tick(grid, wires) || break
    end
end


function part1(data)
    grid, _, wires = parsegrid(data)
    _powerup(grid, wires)
    zs = filter(startswith('z'), keys(wires)) |> collect |> sort
    ans = evalpoly(2, [wires[s] for s in zs])
    return ans
end


function _add(grid, width, x, y)
    wires = Dict(s=>false for s in keys(grid))
    _d(x) = lpad(x, 2, '0')
    for (i,t) in enumerate(digits(x, base=2, pad=width))
        wires["x$(_d(i-1))"] = t
    end
    for (i,t) in enumerate(digits(y, base=2, pad=width))
        wires["y$(_d(i-1))"] = t
    end
    _powerup(grid, wires)
    z = Bool[]
    for i in Iterators.countfrom(0)
        t = get(wires, "z$(_d(i))", nothing)
        isnothing(t) && break
        push!(z, t)
    end
    return evalpoly(2, z)
end


function part2(data)
    grid, nets, wires = parsegrid(data)
    width = count(startswith('x'), keys(wires))

    function isvalid(i)
        for x in [0, 1 << (i-1)], y in [0, 1 << (i-1)]
            c = ((x + y) >> (i-1)) & 1
            z = _add(grid, width, x, y)
            t = digits(z, base=2, pad=width)[i]
            t != c && return false
        end
        return true
    end

    function findfix(i)
        x,y,z = ("$c$(lpad(i-1,2,'0'))" for c in "xyz")
        nx, na = nets[x]
        if grid[nx][1] != (⊻)
            nx, na = na, nx
        end
        @assert grid[nx][1] == (⊻)
        @assert grid[na][1] == (&)
        if z ∉ nets[nx]
            for q in nets[nx]
                grid[q][1] == (⊻) && return (q, z)
            end
            return (nx, na)
        end
        if grid[z][1] != (⊻)
            for q in nets[nx]
                grid[q][1] == (⊻) && return (q, z)
            end
        end
        error()
    end

    res = AbstractString[]
    for i in 1:width
        if !isvalid(i)
            a, b = findfix(i)
            grid[a], grid[b] = grid[b], grid[a]
            append!(res, [a, b])
        end
    end
    @assert _add(grid, width, 16505452623174, 7668612819043) == 24174065442217
    ans = join(sort(res), ',')
    return ans
end


data = """
x00: 1
x01: 1
x02: 1
y00: 0
y01: 1
y02: 0

x00 AND y00 -> z00
x01 XOR y01 -> z01
x02 OR y02 -> z02
"""
@assert part1(data) == 4


data = """
x00: 1
x01: 0
x02: 1
x03: 1
x04: 0
y00: 1
y01: 1
y02: 1
y03: 1
y04: 1

ntg XOR fgs -> mjb
y02 OR x01 -> tnw
kwq OR kpj -> z05
x00 OR x03 -> fst
tgd XOR rvg -> z01
vdt OR tnw -> bfw
bfw AND frj -> z10
ffh OR nrd -> bqk
y00 AND y03 -> djm
y03 OR y00 -> psh
bqk OR frj -> z08
tnw OR fst -> frj
gnj AND tgd -> z11
bfw XOR mjb -> z00
x03 OR x00 -> vdt
gnj AND wpb -> z02
x04 AND y00 -> kjc
djm OR pbm -> qhw
nrd AND vdt -> hwm
kjc AND fst -> rvg
y04 OR y02 -> fgs
y01 AND x02 -> pbm
ntg OR kjc -> kwq
psh XOR fgs -> tgd
qhw XOR tgd -> z09
pbm OR djm -> kpj
x03 XOR y03 -> ffh
x00 XOR y04 -> ntg
bfw OR bqk -> z06
nrd XOR fgs -> wpb
frj XOR qhw -> z04
bqk OR frj -> z07
y03 OR x01 -> nrd
hwm AND bqk -> z03
tgd XOR rvg -> z12
tnw OR pbm -> gnj
"""
@assert part1(data) == 2024


data = readchomp("day24.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
