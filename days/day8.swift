#!/usr/bin/env swift
import Foundation


struct V2 : Hashable {
    var x: Int
    var y: Int

    static let zero = V2(x: 0, y: 0)
}


func parseWorld(_ data: String) -> (V2, [Character:[V2]]) {
    let h = data.split(separator: "\n").count
    let w = data.split(separator: "\n").first!.count
    let src: [Character:[V2]] = data
        .split(separator: "\n")
        .lazy
        .enumerated()
        .flatMap { p in Array(p.element).lazy.enumerated().compactMap { q in
            q.element == "." ? nil :
            (q.element, V2(x: q.offset, y: p.offset)) } }
        .reduce(into: [:], { acc, p in acc[p.0, default:[]].append(p.1) })
    return (V2(x: w, y: h), src)
}


func part1(_ data: String) -> Int {
    let (size, src) = parseWorld(data)

    func check(_ a: V2, _ b: V2) -> V2? {
        let x = a.x + a.x - b.x
        let y = a.y + a.y - b.y
        guard x >= 0 && y >= 0 && x < size.x && y < size.y
        else { return nil }
        return V2(x: x, y: y)
    }

    var pois: Set<V2> = []
    for (_, ps) in src {
        for (i, s) in ps.enumerated() {
            for t in ps.dropFirst(i+1) {
                if let p = check(s, t) {
                    pois.insert(p)
                }
                if let p = check(t, s) {
                    pois.insert(p)
                }
            }
        }
    }
    return pois.count
}


func part2(_ data: String) -> Int {
    let (size, src) = parseWorld(data)

    func check(_ a: V2, _ b: V2) -> some Sequence<V2> {
        let dx = b.x - a.x
        let dy = b.y - a.y
        var x = a.x + dx
        var y = a.y + dy
        var t = 0
        while x >= 0 && y >= 0 && x < size.x && y < size.y {
            t += 1
            x += dx
            y += dy
        }
        return (1...t)
            .lazy
            .map { i in V2(x: a.x + i * dx, y: a.y + i * dy) }
    }

    var pois: Set<V2> = []
    for (_, ps) in src {
        for (i, s) in ps.enumerated() {
            for t in ps.dropFirst(i+1) {
                for p in check(s, t) {
                    pois.insert(p)
                }
                for p in check(t, s) {
                    pois.insert(p)
                }
            }
        }
    }
    return pois.count
}


let test = """
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
"""
assert(part1(test) == 14)
assert(part2(test) == 34)


let data = try! String(contentsOfFile: "day8.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
