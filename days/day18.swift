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

    static func parse<S,T>(x: S, y: T) -> V2
        where S:StringProtocol, T:StringProtocol {
        V2(x: Int(x)!, y: Int(y)!)
    }
}


func part1(_ data: String, w: Int = 71, h: Int = 71, n: Int = 1024) -> Int {
    let corrupt = Set(data.matches(of: #/(\d+),(\d+)/#)[..<n].map {
        V2.parse(x: $0.1, y: $0.2) })
    let start = V2(x: 0, y: 0)
    let goal = V2(x: w - 1, y: h - 1)
    let rwidth = 0..<w
    let rheight = 0..<h

    var fringe: [(Int,V2)] = [(0, start)]
    var seen: Set<V2> = []

    while let (distance, pos) = fringe.first {
        fringe.removeFirst()
        if pos == goal {
            return distance
        }

        if seen.contains(pos) {
            continue
        }
        seen.insert(pos)

        for d in V2.around {
            let q = pos + d
            if rwidth.contains(q.x) && rheight.contains(q.y) {
                if !corrupt.contains(q) {
                    fringe.append((distance + 1, q))
                }
            }
        }
    }

    fatalError()
}


func findPath(start: V2, goal: V2, rect: V2, corrupt: Set<V2>) -> [V2]? {
    let rwidth = 0..<rect.x
    let rheight = 0..<rect.y
    var fringe: [[V2]] = [[start]]
    var seen: Set<V2> = []

    while let path = fringe.first, let pos = path.last {
        fringe.removeFirst()
        if pos == goal {
            return path
        }

        if seen.contains(pos) {
            continue
        }
        seen.insert(pos)

        for d in V2.around {
            let q = pos + d
            if rwidth.contains(q.x) && rheight.contains(q.y) {
                if !corrupt.contains(q) {
                    fringe.append(path + [q])
                }
            }
        }
    }

    return nil
}


func part2(_ data: String, w: Int = 71, h: Int = 71) -> String {
    let corrupt = data.matches(of: #/(\d+),(\d+)/#).map {
        V2.parse(x: $0.1, y: $0.2) }
    let rect = V2(x: w, y: h)
    let start = V2(x: 0, y: 0)
    let goal = V2(x: w - 1, y: h - 1)

    var stones: Set<V2> = []
    var path: Set<V2>

    guard let ps = findPath(start: start, goal: goal, rect: rect, corrupt: stones)
    else { fatalError() }
    path = Set(ps)

    for stone in corrupt {
        stones.insert(stone)

        if path.contains(stone) {
            guard let ps = findPath(start: start, goal: goal, rect: rect, corrupt: stones)
            else { return "\(stone.x),\(stone.y)" }
            path = Set(ps)
        }
    }

    fatalError()
}


let test = """
5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0
"""
assert(part1(test, w: 7, h: 7, n: 12) == 22)
assert(part2(test, w: 7, h: 7) == "6,1")


let data = try! String(contentsOfFile: "day18.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
