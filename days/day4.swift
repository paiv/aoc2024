#!/usr/bin/env swift
import Foundation


func is_xmas(_ text: String) -> Bool {
    return text == "XMAS" || text == "SAMX"
}


func is_mas(_ text: String) -> Bool {
    return text == "MAS" || text == "SAM"
}


func row_words(_ data: [[Character]]) -> some Sequence<String> {
    data.lazy.flatMap { row in
        (0..<(row.count - 3)).lazy.map { i in
            String(row[i..<(i+4)])
        }
    }
}


func col_words(_ data: [[Character]]) -> some Sequence<String> {
    (0..<(data.count - 3)).lazy.flatMap { r in
        let r1 = data[r]
        let r2 = data[r + 1]
        let r3 = data[r + 2]
        let r4 = data[r + 3]
        return (0..<r1.count).lazy.map { i in
            String([r1[i], r2[i], r3[i], r4[i]])
        }
    }
}


func diag_words(_ data: [[Character]]) -> some Sequence<String> {
    (0..<(data.count - 3)).lazy.flatMap { r in
        let r1 = data[r]
        let r2 = data[r + 1]
        let r3 = data[r + 2]
        let r4 = data[r + 3]
        let rs = 0..<(r1.count - 3)
        return rs.lazy.flatMap { i in
            [
                String([r1[i], r2[i+1], r3[i+2], r4[i+3]]),
                String([r1[i+3], r2[i+2], r3[i+1], r4[i]])
            ]
        }
    }
}


func x_words(_ data: [[Character]]) -> some Sequence<(String,String)> {
    let ls = 0..<(data.count - 2)
    return ls.lazy.flatMap { r in
        let r1 = data[r]
        let r2 = data[r + 1]
        let r3 = data[r + 2]
        let rs = 0..<(r1.count - 2)
        return rs.lazy.map { i in
            (
                String([r1[i], r2[i+1], r3[i+2]]),
                String([r1[i+2], r2[i+1], r3[i]])
            )
        }
    }
}


func part1(_ data: String) -> Int {
    let data = data.split(separator: "\n").map(Array.init)
    let words = [
        row_words(data).map{$0},
        col_words(data).map{$0},
        diag_words(data).map{$0},
    ].joined()
    let ans = words.count(where: { is_xmas($0) })
    return ans
}


func part2(_ data: String) -> Int {
    let data = data.split(separator: "\n").map(Array.init)
    let words = x_words(data)
    let ans = words.count(where: { is_mas($0.0) && is_mas($0.1) })
    return ans
}


let test1 = """
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"""
assert(part1(test1) == 18)
assert(part2(test1) == 9)


let data = try! String(contentsOfFile: "day4.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
