#!/usr/bin/env swift
import Foundation


func part1(_ data: String) -> Int {
    let data = data.split(separator: "\n").map(String.init)
    let avail = data[0].split(separator: ",").flatMap {
        $0.split(separator: " ") }
    var memo: [String:Int] = [:]

    func check(_ s: String) -> Int {
        if s.isEmpty { return 1 }
        if let n = memo[s] { return n }
        for p in avail {
            if s.hasPrefix(p) {
                let t = s.dropFirst(p.count)
                if check(String(t)) != 0 {
                    memo[s] = 1
                    return 1
                }
            }
        }
        memo[s] = 0
        return 0
    }

    let ans = data[1...].map(check).reduce(0, +)
    return ans
}


func part2(_ data: String) -> Int {
    let data = data.split(separator: "\n").map(String.init)
    let avail = data[0].split(separator: ",").flatMap {
        $0.split(separator: " ") }
    var memo: [String:Int] = [:]

    func check(_ s: String) -> Int {
        if s.isEmpty { return 1 }
        if let n = memo[s] { return n }
        var res = 0
        for p in avail {
            if s.hasPrefix(p) {
                let t = s.dropFirst(p.count)
                res += check(String(t))
            }
        }
        memo[s] = res
        return res
    }

    let ans = data[1...].map(check).reduce(0, +)
    return ans
}


let test = """
r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb
"""
assert(part1(test) == 6)
assert(part2(test) == 16)


let data = try! String(contentsOfFile: "day19.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
