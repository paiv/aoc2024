#!/usr/bin/env swift
import Foundation


struct V2 : Hashable {
    var x: Int
    var y: Int

    static let up = V2(x: 0, y: -1)
    static let down = V2(x: 0, y: 1)
    static let left = V2(x: -1, y: 0)
    static let right = V2(x: 1, y: 0)

    static func + (_ a: V2, _ b: V2) -> V2 {
        V2(x: a.x + b.x, y: a.y + b.y)
    }

    static func * (_ a: V2, _ b: V2) -> V2 {
        V2(x: a.x * b.x, y: a.y * b.y)
    }

    static func * (_ a: V2, _ c: Int) -> V2 {
        V2(x: a.x * c, y: a.y * c)
    }
}


func part1_parse(_ data: String) -> ([V2:Character], V2, [V2]) {
    let parts = data.split(separator: "\n\n")

    let mop: [Character: V2] = ["^": V2.up, "v": V2.down, "<": V2.left, ">": V2.right]
    let prog = parts[1].split(separator: "\n").flatMap { s in s.map { mop[$0]! } }

    var grid: [V2:Character] = parts[0]
        .split(separator: "\n")
        .enumerated()
        .flatMap { p in Array(p.element).enumerated().compactMap { q in
            q.element == "#" ? nil :
                (q.element, V2(x: q.offset, y: p.offset)) } }
        .reduce(into: [:], { acc, p in acc[p.1] = p.0 })
    let start = grid.first(where: { $0.value == "@" })!.key
    grid[start] = "."
    return (grid, start, prog)
}


func part1(_ data: String) -> Int {
    let (grid1, start, prog) = part1_parse(data)
    var grid = grid1
    var pos = start

    for op in prog {
        let next = pos + op

        guard let value = grid[next]
        else { continue }

        switch (value) {
            case ".":
                pos = next
            case "O":
                for i in 1... {
                    guard let c = grid[pos + op * i]
                    else { break }
                    if c == "." {
                        for j in (1..<i).reversed() {
                            grid[pos + op * (j + 1)] = "O"
                            grid[pos + op * j] = "."
                        }
                        pos = next
                        break
                    }
                }
            default:
                fatalError()
        }
    }
    let ans = grid
        .map { p in p.value != "O" ? 0 : p.key.x + 100 * p.key.y }
        .reduce(0, +)
    return ans
}


func part2_parse(_ data: String) -> ([V2:Character], V2, [V2]) {
    let parts = data.split(separator: "\n\n")

    let mop: [Character: V2] = ["^": V2.up, "v": V2.down, "<": V2.left, ">": V2.right]
    let prog = parts[1].split(separator: "\n").flatMap { s in s.map { mop[$0]! }}

    let blow = ["O": "[]", ".": "..", "#": "##", "@": "@.", "\n": "\n"]
    let sgrid = parts[0].replacing(#/./#, with: { m in blow[String(m.0)]! })
    var grid: [V2:Character] = sgrid
        .split(separator: "\n")
        .enumerated()
        .flatMap { p in Array(p.element).enumerated().compactMap { q in
            q.element == "#" ? nil :
                (q.element, V2(x: q.offset, y: p.offset)) } }
        .reduce(into: [:], { acc, p in acc[p.1] = p.0 })
    let start = grid.first(where: { $0.value == "@" })!.key
    grid[start] = "."
    return (grid, start, prog)
}


func part2(_ data: String) -> Int {
    let (grid1, start, prog) = part2_parse(data)
    var grid = grid1
    var pos = start

    for op in prog {
        let next = pos + op

        guard let value = grid[next]
        else { continue }

        switch (value) {
            case ".":
                pos = next
            case "[", "]":
                if op == V2.left || op == V2.right {
                    for i in 1... {
                        guard let c = grid[pos + op * i]
                        else { break }
                        if c == "." {
                            for j in (1..<i).reversed() {
                                grid[pos + op * (j + 1)] = grid[pos + op * j]
                                grid[pos + op * j] = "."
                            }
                            pos = next
                            break
                        }
                    }
                }
                else {
                    var fringe = [[pos]]
                    while true {
                        let qs = fringe.last!.map { $0 + op }
                        let ps = qs.map { grid[$0] }
                        guard ps.allSatisfy({ $0 != nil })
                        else { break }
                        if ps.allSatisfy({ $0 == "." }) {
                            for qs in fringe.reversed() {
                                for q in qs {
                                    grid[q + op] = grid[q]!
                                    grid[q] = "."
                                }
                            }
                            pos = next
                            break
                        }
                        else {
                            var wave: Set<V2> = []
                            for q in qs {
                                switch grid[q] {
                                    case "]":
                                        wave.insert(q)
                                        wave.insert(q + V2.left)
                                    case "[":
                                        wave.insert(q)
                                        wave.insert(q + V2.right)
                                    default:
                                        break
                                }
                            }
                            fringe.append(Array(wave))
                        }
                    }
                }
            default:
                fatalError()
        }
    }
    let ans = grid
        .map { p in p.value != "[" ? 0 : p.key.x + 100 * p.key.y }
        .reduce(0, +)
    return ans
}


let test = """
##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
"""
assert(part1(test) == 10092)
assert(part2(test) == 9021)


let data = try! String(contentsOfFile: "day15.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
