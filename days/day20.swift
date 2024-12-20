#!/usr/bin/env swift
import Foundation


struct V2 : Hashable {
    var x: Int
    var y: Int

    static let up = V2(x: 0, y: -1)
    static let down = V2(x: 0, y: 1)
    static let left = V2(x: -1, y: 0)
    static let right = V2(x: 1, y: 0)
    static let around = [V2.right, V2.down, V2.left, V2.up]

    static func + (a: Self, b: Self) -> V2 {
        V2(x: a.x + b.x, y: a.y + b.y)
    }
}


struct Problem {
    var grid: Set<V2>
    var start: V2
    var goal: V2
}


func parseProblem(_ data: String) -> Problem {
    let grid: [V2:Character] = data
        .split(separator: "\n")
        .enumerated()
        .flatMap { p in Array(p.element).enumerated().compactMap { q in
            q.element == "#" ? nil :
                (q.element, V2(x: q.offset, y: p.offset)) } }
        .reduce(into: [:], { acc, p in acc[p.1] = p.0 })
    let start = grid.first(where: { $0.value == "S" })!.key
    let goal = grid.first(where: { $0.value == "E" })!.key
    return Problem(grid: Set(grid.keys), start: start, goal: goal)
}


func part1(_ data: String, n: Int = 100, t: Int = 2) -> Int {
    let prob = parseProblem(data)

    func findPaths(_ start: V2) -> [V2:Int] {
        var fringe: [(Int,V2)] = [(0, start)]
        var seen: [V2:Int] = [:]

        while let (distance, pos) = fringe.first {
            fringe.removeFirst()
            if seen.keys.contains(pos) {
                continue
            }
            seen[pos] = distance

            for d in V2.around {
                if prob.grid.contains(pos + d) {
                    fringe.append((distance + 1, pos + d))
                }
            }
        }

        return seen
    }

    let from_start = findPaths(prob.start)
    let to_end = findPaths(prob.goal)
    let base = from_start[prob.goal]!
    var ans = 0

    for (pos, dt) in from_start {
        for v in (1 ... t) {
            for x in (-v ... v) {
                for y in [v - abs(x), -v + abs(x)] {
                    let q = pos + V2(x: x, y: y)
                    if let w = to_end[q] {
                        let ok = base - (dt + v + w) >= n
                        ans += ok ? 1 : 0
                    }
                    if y == 0 { break }
                }
            }
        }
    }

    return ans
}


func part2(_ data: String, n: Int = 100, t: Int = 20) -> Int {
    part1(data, n: n, t: t)
}


let test = """
###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############
"""
assert(part1(test, n: 38) == 3)
assert(part2(test, n: 76) == 3)


let data = try! String(contentsOfFile: "day20.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
