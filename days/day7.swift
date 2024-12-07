#!/usr/bin/env swift
import Foundation


func valid(_ xs: [Int], _ test: Int, ops: Int) -> Bool {
    guard let x = xs.first
    else { return false }
    var acc = [x]
    for y in xs.dropFirst(1) {
        acc = acc.flatMap { x in
            ops == 3 ?
            [
                x + y,
                x * y,
                Int(String(x) + String(y))!,
            ] :
            [
                x + y,
                x * y,
            ]
        }
    }
    return acc.contains(test)
}


func part1(_ data: String, _ ops: Int = 2) -> Int {
    var ans = 0
    for line in data.split(separator: "\n") {
        let cs = line.split(separator: ":")
        let t = Int(cs[0])!
        let xs = cs[1].split(separator: " ").map { Int($0)! }
        if valid(xs, t, ops: ops) {
            ans += t
        }
    }
    return ans
}


func part2(_ data: String) -> Int {
    return part1(data, 3)
}


let test = """
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
"""
assert(part1(test) == 3749)
assert(part2(test) == 11387)


let data = try! String(contentsOfFile: "day7.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
