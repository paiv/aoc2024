#!/usr/bin/env swift
import Foundation


func part1(_ data: String) -> Int {
    let data = data.matches(of: #/\d/#).map({ Int($0.0)! })
    var disk: [Int] = []

    for (i, n) in data.enumerated() {
        if i % 2 == 0 {
            let fid = i / 2 + 1
            disk.append(contentsOf: Array(repeating: fid, count: n))
        }
        else {
            disk.append(contentsOf: Array(repeating: 0, count: n))
        }
    }

    var l = disk.firstIndex(of: 0)!
    var r = disk.endIndex - 1
    while l < r {
        let x = disk[r]
        if x != 0 {
            disk[l] = x
            disk[r] = 0
            l = disk[(l+1)...].firstIndex(of: 0)!
        }
        r -= 1
    }
    let ans = disk
        .lazy
        .map { max(0, $0 - 1) }
        .enumerated()
        .reduce(0, { acc, p in acc + p.offset * p.element })
    return ans
}


func part2(_ data: String) -> Int {
    let data = data.matches(of: #/\d/#).map({ Int($0.0)! })
    var disk: [[Int]] = data.map { _ in [] }
    var space: [Int] = data.enumerated().map { p in
        p.offset % 2 == 0 ? 0 : p.element }

    for i in stride(from: 0, to: data.count, by: 2).reversed() {
        let n = data[i]
        var moved = false
        for j in 0..<i {
            if n <= space[j] {
                space[j] -= n
                space[i] += n
                disk[j].append(i)
                moved = true
                break
            }
        }
        if !moved {
            disk[i].append(i)
        }
    }

    var ans = 0
    var i = 0
    for (j, ps) in disk.enumerated() {
        for x in ps {
            for _ in 0..<data[x] {
                ans += i * (x / 2)
                i += 1
            }
        }
        i += space[j]
    }
    return ans
}


let test = """
2333133121414131402
"""
assert(part1(test) == 1928)
assert(part2(test) == 2858)


let data = try! String(contentsOfFile: "day9.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
