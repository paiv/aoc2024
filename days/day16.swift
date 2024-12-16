#!/usr/bin/env swift
import Foundation


struct V2 : Hashable, Comparable {
    var x: Int
    var y: Int

    static let east = V2(x: 1, y: 0)
    static let i = V2(x: 0, y: 1)

    static func < (a: Self, b: Self) -> Bool {
        return a.y < b.y || (a.y == b.y && a.x < b.x)
    }

    static func + (a: Self, b: Self) -> V2 {
        V2(x: a.x + b.x, y: a.y + b.y)
    }

    static func * (a: Self, b: Self) -> V2 {
        V2(x: a.x * b.x - a.y * b.y, y: a.x * b.y + a.y * b.x)
    }

    static func *= (a: inout Self, b: Self) {
        let ax = a.x
        a.x = ax * b.x - a.y * b.y
        a.y = ax * b.y + a.y * b.x
    }
}


struct Pos : Hashable {
    var pos: V2
    var dir: V2
}


struct Problem {
    var grid: Set<V2>
    var start: V2
    var goal: V2
}


struct Step : Comparable {
    var dist: Int
    var pos: Pos

    static func < (a: Self, b: Self) -> Bool {
        a.dist < b.dist ||
        (a.dist == b.dist && (a.pos.pos < b.pos.pos ||
        (a.pos.pos == b.pos.pos && a.pos.dir < b.pos.dir)
        ))
    }
}


func part1_parse(_ data: String) -> Problem {
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


func part1(_ data: String) -> Int {
    let prob = part1_parse(data)
    var fringe = PriorityQueue<Step>()
    var seen: Set<Pos> = []

    fringe.push(Step(dist: 0, pos: Pos(pos: prob.start, dir: V2.east)))

    while let step = fringe.pop() {
        let spos = step.pos
        let pos = spos.pos
        var dir = spos.dir

        if pos == prob.goal {
            return step.dist
        }

        if seen.contains(spos) {
            continue
        }
        seen.insert(spos)

        if prob.grid.contains(pos + dir) {
            fringe.push(Step(dist: step.dist + 1, pos: Pos(pos: pos + dir, dir: dir)))
        }

        for _ in 0..<3 {
            dir *= V2.i
            fringe.push(Step(dist: step.dist + 1000, pos: Pos(pos: pos, dir: dir)))
        }
    }
    fatalError()
}


struct Step2 : Comparable {
    var dist: Int
    var prev: Int
    var pos: Pos

    static func < (a: Self, b: Self) -> Bool {
        a.dist < b.dist ||
        (a.dist == b.dist && (a.prev < b.prev ||
        (a.prev == b.prev && (a.pos.pos < b.pos.pos ||
        (a.pos.pos == b.pos.pos && a.pos.dir < b.pos.dir)
        ))))
    }
}


func part2(_ data: String) -> Int {
    let prob = part1_parse(data)
    var prev: [(Int, V2)] = []
    var terms: [(Int, V2)] = []
    var fringe = PriorityQueue<Step2>()
    var seen: [Pos:Int] = [:]

    fringe.push(Step2(dist: 0, prev: -1, pos: Pos(pos: prob.start, dir: V2.east)))
    var best = Int.max

    while let step = fringe.pop() {
        let spos = step.pos
        let pos = spos.pos
        var dir = spos.dir

        if step.dist > best {
            break
        }

        if pos == prob.goal {
            if step.dist < best {
                best = step.dist
                terms = []
            }
            terms.append((step.prev, pos))
        }

        if seen[spos, default: Int.max] < step.dist {
            continue
        }
        seen[spos] = step.dist

        if prob.grid.contains(pos + dir) {
            fringe.push(Step2(dist: step.dist + 1, prev: prev.count,
                pos: Pos(pos: pos + dir, dir: dir)))
            prev.append((step.prev, pos))
        }

        for _ in 0..<3 {
            dir *= V2.i
            fringe.push(Step2(dist: step.dist + 1000, prev: prev.count,
                pos: Pos(pos: pos, dir: dir)))
            prev.append((step.prev, pos))
        }
    }

    var res: Set<V2> = []
    for t in terms {
        var (i, pos) = t
        while i >= 0 {
            res.insert(pos)
            pos = prev[i].1
            i = prev[i].0
        }
    }
    return res.count
}


let test = """
#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################
"""
assert(part1(test) == 11048)
assert(part2(test) == 64)


let data = try! String(contentsOfFile: "day16.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
