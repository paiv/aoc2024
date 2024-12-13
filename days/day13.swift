#!/usr/bin/env swift
import Foundation


func part1(_ data: String, N: Int = 0) -> Int {
    let data = data.matches(of: #/[+-]?\d+/#).map { Int($0.0)! }
    var ans = 0
    for i in stride(from: 0, to: data.count, by: 6) {
        let ax = data[i+0]
        let ay = data[i+1]
        let bx = data[i+2]
        let by = data[i+3]
        let px = data[i+4] + N
        let py = data[i+5] + N

        let un = px * ay - py * ax
        let ud = ay * bx - ax * by
        if un.isMultiple(of: ud) {
            let u = un / ud
            let vn = px - bx * u
            if vn.isMultiple(of: ax) {
                ans += u + vn / ax * 3
            }
        }
    }
    return ans
}


func part2(_ data: String) -> Int {
    part1(data, N: 10000000000000)
}


let test = """
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
"""
assert(part1(test) == 480)


let data = try! String(contentsOfFile: "day13.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
