#!/usr/bin/env swift
import Foundation


struct V2 : Hashable {
    var x: Int
    var y: Int

    static func + (a: V2, b: V2) -> V2 {
        V2(x: a.x + b.x, y: a.y + b.y)
    }
}


func parseWorld(_ data: String) -> (V2, [V2:Int]) {
    let h = data.split(separator: "\n").count
    let w = data.split(separator: "\n").first!.count
    let src: [V2:Int] = data
        .split(separator: "\n")
        .enumerated()
        .flatMap { p in Array(p.element).enumerated().map { q in
            (Int(String(q.element))!, V2(x: q.offset, y: p.offset)) } }
        .reduce(into: [:], { acc, p in acc[p.1] = p.0 })
    return (V2(x: w, y: h), src)
}


func part1(_ data: String) -> Int {
    let (_, world) = parseWorld(data)
    let starts = world.compactMap { $0.value == 0 ? $0.key : nil }
    let neib = [V2(x:1, y:0), V2(x:-1, y:0), V2(x:0, y:1), V2(x:0, y:-1)]

    var ans = 0
    for s in starts {
        var fringe = [s]
        var seen: Set<V2> = [s]
        while !fringe.isEmpty {
            let pos = fringe.removeFirst()
            guard let alt = world[pos]
            else { continue }
            if alt == 9 {
                ans += 1
                continue
            }
            for d in neib {
                let q = pos + d
                if let h = world[q], h - alt == 1 {
                    if !seen.contains(q) {
                        seen.insert(q)
                        fringe.append(q)
                    }
                }
            }
        }
    }
    return ans
}


func part2(_ data: String) -> Int {
    let (_, world) = parseWorld(data)
    let starts = world.compactMap { $0.value == 0 ? $0.key : nil }
    let neib = [V2(x:1, y:0), V2(x:-1, y:0), V2(x:0, y:1), V2(x:0, y:-1)]

    var ans = 0
    for s in starts {
        var fringe: [(V2, [V2])] = [(s, [])]
        while !fringe.isEmpty {
            let (pos, path) = fringe.removeFirst()
            guard let alt = world[pos]
            else { continue }
            if alt == 9 {
                ans += 1
                continue
            }
            for d in neib {
                let q = pos + d
                if let h = world[q], h - alt == 1 {
                    if !path.contains(q) {
                        fringe.append((q, path + [q]))
                    }
                }
            }
        }
    }
    return ans
}


let test = """
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
"""
assert(part1(test) == 36)
assert(part2(test) == 81)


let data = try! String(contentsOfFile: "day10.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
