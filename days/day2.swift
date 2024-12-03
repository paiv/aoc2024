#!/usr/bin/env swift
import Foundation


func is_safe(_ data: [Int]) -> Bool {
    data[1...].enumerated().allSatisfy { p in [1,2,3].contains(p.element - data[p.offset]) }
    ||
    data[1...].enumerated().allSatisfy { p in [1,2,3].contains(data[p.offset] - p.element) }
}


func is_tolerable(_ data: [Int]) -> Bool {
    is_safe(data) ||
        !(0..<data.count)
            .allSatisfy { i in
                !is_safe(Array(data.prefix(upTo: i)) + Array(data.suffix(from: i+1)))
            }
}


func part1(_ data: String) -> Int {
    data
        .split(separator: "\n")
        .map { s in s.split(separator: " ").map { Int($0)! }}
        .map { is_safe($0) ? 1 : 0 }
        .reduce(0, +)
}


func part2(_ data: String) -> Int {
    data
        .split(separator: "\n")
        .map { s in s.split(separator: " ").map { Int($0)! }}
        .map { is_tolerable($0) ? 1 : 0 }
        .reduce(0, +)
}


let test1 = """
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"""
assert(part1(test1) == 2)
assert(part2(test1) == 4)


let data = try! String(contentsOfFile: "day2.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
