#!/usr/bin/env julia


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
    ans = 0
    for t in ts
        ix = [n for n in findall(links[t,:]) if n ∉ ts || n < t]
        for j in ix, i in ix
            (j < i) && (ans += links[i, j])
        end
    end
    return ans
end


function _connect(links, row, cliq, seen)
    best = cliq
    for j in findall(links[row,:])
        j <= seen && continue
        if all(links[i, j] for i in cliq)
            n = _connect(links, row, [cliq; j], j)
            if length(best) < length(n)
                best = n
            end
        end
    end
    return best
end


function part2(data)
    names, links = parsedata(data)
    best = Int[]
    for a in keys(names)
        n = _connect(links, a, [a], a)
        if length(best) < length(n)
            best = n
        end
    end
    ans = join(sort(names[best]), ',')
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
