#!/usr/bin/env swift
import Foundation


struct V2 : Hashable {
    var x: Int
    var y: Int

    static let i = V2(x: 0, y: 1)

    static func + (a: V2, b: V2) -> V2 {
        V2(x: a.x + b.x, y: a.y + b.y)
    }

    static func += (a: inout V2, b: V2) {
        a.x += b.x
        a.y += b.y
    }

    static func * (a: V2, b: V2) -> V2 {
        V2(x: a.x * b.x - a.y * b.y, y: a.x * b.y + a.y * b.x)
    }

    static func *= (a: inout V2, b: V2) {
        let ax = a.x
        a.x = ax * b.x - a.y * b.y
        a.y = ax * b.y + a.y * b.x
    }
}


struct Pos : Hashable {
    var pos: V2
    var dir: V2
}


func parseWorld(_ data: String) -> [V2:Character] {
    data
        .split(separator: "\n")
        .lazy
        .enumerated()
        .flatMap { p in Array(p.element).lazy.enumerated().map { q in
            (V2(x:q.offset, y:p.offset), q.element) } }
        .reduce(into: [:], { acc, p in acc[p.0] = p.1 })
}


func part1(_ data: String) -> Int {
    let world = parseWorld(data)
    let start = world.first(where: { p in p.value == "^" })!.key
    var seen: Set<V2> = Set()
    var pos = start
    var dir = V2(x: 0, y: -1)

    while let c = world[pos + dir] {
        if c == "#" {
            dir *= V2.i
        }
        else {
            pos += dir
            seen.insert(pos)
        }
    }

    return seen.count;
}


func part2(_ data: String) -> Int {
    let world = parseWorld(data)
    let start = world.first(where: { p in p.value == "^" })!.key

    func oracle(pos: V2, dir: V2, seen: Set<Pos>) -> Bool {
        var world = world
        world[pos + dir] = "#"
        var pos = pos, dir = dir, seen = seen
        while let c = world[pos + dir] {
            if c == "#" {
                dir *= V2.i
            }
            else {
                pos += dir
            }
            let k = Pos(pos: pos, dir: dir)
            if seen.contains(k) {
                return true
            }
            seen.insert(k)
        }
        return false
    }

    var ans = 0
    var seen: Set<Pos> = Set()
    var pos = start
    var dir = V2(x: 0, y: -1)

    while let c = world[pos + dir] {
        if c == "#" {
            dir *= V2.i
        }
        else {
            pos += dir
        }
        ans += oracle(pos: pos, dir: dir, seen: seen) ? 1 : 0
        seen.insert(Pos(pos: pos, dir: dir))
    }
    return ans;
}


let test1 = """
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
"""
assert(part1(test1) == 41)
assert(part2(test1) == 6)


let data = try! String(contentsOfFile: "day6.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
