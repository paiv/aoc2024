#!/usr/bin/env swift
import Foundation


func part1(_ data: String) -> Int {
    data
        .matches(of: #/mul\((\d+),(\d+)\)/#)
        .map({m in (Int(m.1)! * Int(m.2)!)})
        .reduce(0, +)
}


func part2(_ data: String) -> Int {
    let rx = #/do\(\)|don't\(\)|mul\((\d+),(\d+)\)/#
    var ans = 0
    var state = true
    for m in data.matches(of: rx) {
        switch m.0.prefix(3) {
            case "do(": state = true
            case "don": state = false
            case "mul":
                if state {
                    ans += Int(m.1!)! * Int(m.2!)!
                }
            case _: fatalError()
        }
    }
    return ans
}


let test1 = """
xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
"""
assert(part1(test1) == 161)

let test2 = """
xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
"""
assert(part2(test2) == 48)


let data = try! String(contentsOfFile: "day3.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
