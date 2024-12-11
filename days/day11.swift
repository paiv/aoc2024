#!/usr/bin/env swift
import Foundation


func part1(_ data: String, N: Int = 25) -> Int {
    var stones: [Int:Int] = data.matches(of: #/\d+/#)
        .reduce(into: [:], { acc, m in acc[Int(m.0)!] = 1 })
    for _ in 0..<N {
        var state: [Int:Int] = [:]
        for (x, n) in stones {
            if x == 0 {
                state[1, default: 0] += n
            }
            else {
                let s = String(x)
                let ix = s.indices
                if ix.count % 2 == 0 {
                    let h = s.index(s.startIndex, offsetBy: ix.count / 2)
                    let a = Int(s[..<h])!
                    let b = Int(s[h...])!
                    state[a, default: 0] += n
                    state[b, default: 0] += n
                }
                else {
                    state[x * 2024, default: 0] += n
                }
            }
        }
        stones = state
    }
    let ans = stones.reduce(0, { acc, p in acc + p.value })
    return ans
}


func part2(_ data: String) -> Int {
    part1(data, N: 75)
}


let test = """
125 17
"""
assert(part1(test) == 55312)


let data = try! String(contentsOfFile: "day11.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
