#!/usr/bin/env swift
import Foundation


func parseSchematics(_ data: String) -> (keys:[[Int]], locks:[[Int]]) {
    var keys: [[Int]] = []
    var locks: [[Int]] = []

    for block in data.split(separator: "\n\n") {
        let lines = block.split(separator: "\n")
        let nums = lines.reduce(into: [0,0,0,0,0]) { acc, s in
            for (i, c) in s.enumerated() {
                acc[i] += c == "#" ? 1 : 0
            }
        }
        if lines.first == "#####" {
            locks.append(nums)
        }
        else {
            keys.append(nums)
        }
    }

    return (keys, locks)
}


func part1(_ data: String) -> Int {
    let (keys, locks) = parseSchematics(data)
    var ans = 0
    for k in keys {
        for q in locks {
            let t = k.enumerated()
                .allSatisfy { $0.element + q[$0.offset] < 8 }
            ans += t ? 1 : 0
        }
    }
    return ans
}


let test = """
#####
.####
.####
.####
.#.#.
.#...
.....

#####
##.##
.#.##
...##
...#.
...#.
.....

.....
#....
#....
#...#
#.#.#
#.###
#####

.....
.....
#.#..
###..
###.#
###.#
#####

.....
.....
.....
#....
#.#..
#.#.#
#####
"""
assert(part1(test) == 3)


let data = try! String(contentsOfFile: "day25.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
