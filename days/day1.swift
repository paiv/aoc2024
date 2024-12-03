#!/usr/bin/env swift
import Foundation


func part1(_ data: String) -> Int {
    let data = data.matches(of: #/(\d+) +(\d+)/#).map({m in (Int(m.1)!, Int(m.2)!)})
    let l = data.map { p in p.0 }
    let r = data.map { p in p.1 }
    let ans = zip(l.sorted(), r.sorted())
        .map { (x,y) in abs(x-y) }
        .reduce(0, +)
    return ans
}


func part2(_ data: String) -> Int {
    let data = data.matches(of: #/(\d+) +(\d+)/#).map({m in (Int(m.1)!, Int(m.2)!)})
    let l = data.map { p in p.0 }
    let r = data.map { p in p.1 }
    let ans = l.map { x in x * r.count(where: {$0 == x}) }
        .reduce(0, +)
    return ans
}


let test1 = """
3   4
4   3
2   5
1   3
3   9
3   3
"""
assert(part1(test1) == 11)
assert(part2(test1) == 31)


let data = try! String(contentsOfFile: "day1.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
