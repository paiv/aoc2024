#!/usr/bin/env julia
#import Pkg; Pkg.add("Graphs")
using Graphs


function parsedata(text)
    names = unique(c for s in split(text) for c in split(s, '-'))
    n = length(names)
    m = falses(n, n)
    for s in split(text)
        a, b = split(s, '-')
        i = findfirst(==(a), names)
        j = findfirst(==(b), names)
        m[i, j] = true
        m[j, i] = true
    end
    return (names, m)
end


function part1(data)
    names, links = parsedata(data)
    ts = [i for (i, s) in enumerate(names) if s[1] == 't']
    g = SimpleGraph(links)
    ans = 0
    for t in ts
        nx = [n for n in neighbors(g, t) if n ∉ ts || n < t]
        for j in nx, i in nx
            (j < i) && (ans += has_edge(g, i, j))
        end
    end
    return ans
end


function part2(data)
    names, links = parsedata(data)
    g = SimpleGraph(links)
    n = argmax(length, maximal_cliques(g))
    ans = join(sort(names[n]), ',')
    return ans
end


data = """
kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn
"""
@assert part1(data) == 7
@assert part2(data) == "co,de,ka,ta"


data = readchomp("day23.in")
println("part1: ", part1(data))
println("part2: ", part2(data))
