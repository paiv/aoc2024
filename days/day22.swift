#!/usr/bin/env swift
import Foundation


func calc(_ seed: Int) -> Int {
    let m = 16777216, n = 2000
    var x = seed
    for _ in 0..<n {
        x = (x ^ (x << 6)) % m
        x = (x ^ (x >> 5)) % m
        x = (x ^ (x &* 2048)) % m
    }
    return x
}


func part1(_ data: String) -> Int {
    let nums = data.matches(of: #/\d+/#).map { Int($0.0)! }

    let ans = nums.map(calc).reduce(0, +)
    return ans
}


struct V4 : Hashable {
    var a, b, c, d: Int

    static func parse<S>(_ data: S) -> V4 where S:RandomAccessCollection<(Int,Int)> {
        V4(
            a: data[data.index(data.startIndex, offsetBy: 0)].1,
            b: data[data.index(data.startIndex, offsetBy: 1)].1,
            c: data[data.index(data.startIndex, offsetBy: 2)].1,
            d: data[data.index(data.startIndex, offsetBy: 3)].1
        )
    }
}


func calcs(_ seed: Int) -> [(Int,Int)] {
    let m = 16777216, n = 2000
    var s = seed % 10
    var x = seed
    return (0..<n).map { _ in
        x = (x ^ (x << 6)) % m
        x = (x ^ (x >> 5)) % m
        x = (x ^ (x &* 2048)) % m
        let k = x % 10
        let r = k - s
        s = k
        return (k, r)
    }
}


func part2(_ data: String) -> Int {
    let nums = data.matches(of: #/\d+/#).map { Int($0.0)! }

    var cache: [V4:Int] = [:]
    for ps in nums.map(calcs) {
        var seen: Set<V4> = []
        for i in (ps.startIndex ..< ps.endIndex - 3) {
            let k = V4.parse(ps[i ..< i + 4])
            if !seen.contains(k) {
                seen.insert(k)
                cache[k, default: 0] += ps[i + 3].0
            }
        }
    }

    return cache.values.max()!
}


let test1 = """
1
10
100
2024
"""
assert(part1(test1) == 37327623)

let test2 = """
1
2
3
2024
"""
assert(part2(test2) == 23)


let data = try! String(contentsOfFile: "day22.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
