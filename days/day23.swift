#!/usr/bin/env swift
import Foundation


func parseGraph(_ data: String) -> [String:Set<String>] {
    data.matches(of: #/(\w+)-(\w+)/#)
        .map { (String($0.1), String($0.2)) }
        .reduce(into: [:]) { (acc, p) in
            acc[p.0, default: []].insert(p.1)
            acc[p.1, default: []].insert(p.0)
        }
}


struct Tre : Hashable {
    var a, b, c: String

    init(a: String, b: String, c: String) {
        let ps = [a, b, c].sorted()
        self.a = ps[0]
        self.b = ps[1]
        self.c = ps[2]
    }
}


func part1(_ data: String) -> Int {
    let graph = parseGraph(data)
    var tres: Set<Tre> = []

    for (k, ps) in graph {
        guard k.first == "t" else { continue }
        for a in ps {
            for b in graph[a]! {
                if graph[b]!.contains(k) {
                    tres.insert(Tre(a: a, b: b, c: k))
                }
            }
        }
    }

    let ans = tres.count
    return ans
}


func part2(_ data: String) -> String {
    let graph = parseGraph(data)
    var best: Set<String> = []

    func clique(_ seed: Set<String>) -> Set<String> {
        var s = seed
        for (k, ps) in graph {
            if s.intersection(ps) == s {
                s.insert(k)
            }
        }
        return s
    }

    for (k, ps) in graph {
        var seen: Set<Tre> = []
        for a in ps {
            for b in graph[a]! {
                if graph[b]!.contains(k) {
                    let t = Tre(a: a, b: b, c: k)
                    guard !seen.contains(t) else { continue }
                    seen.insert(t)

                    let q = clique([a, b, k])
                    if q.count > best.count {
                        best = q
                    }
                }
            }
        }
    }

    let ans = best.sorted().joined(separator: ",")
    return ans
}


let test = """
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
assert(part1(test) == 7)
assert(part2(test) == "co,de,ka,ta")


let data = try! String(contentsOfFile: "day23.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
