#!/usr/bin/env swift
import Foundation


func parseRules(_ data: String) -> [Int:[Int]] {
    data
        .split(separator: "\n\n")[0]
        .matches(of: #/(\d+)\|(\d+)/#)
        .map { m in (Int(m.1)!, Int(m.2)!) }
        .reduce(into: [:], { acc, p in acc[p.0, default: []].append(p.1) })
}


func parseJobs(_ data: String) -> [[Int]] {
    data
        .split(separator: "\n\n")[1]
        .split(separator: "\n")
        .map { s in s.split(separator: ",").map { c in Int(c)! } }
}


func part1(_ data: String) -> Int {
    let rules = parseRules(data)
    let jobs = parseJobs(data)

    func valid(_ job: [Int]) -> Int {
        for (i, x) in job.enumerated() {
            if let ps = rules[x] {
                for p in ps {
                    if job[0..<i].contains(p) {
                        return 0
                    }
                }
            }
        }
        return job[job.count / 2]
    }

    return jobs.map(valid).reduce(0, +)
}


func part2(_ data: String) -> Int {
    let rules = parseRules(data)
    let jobs = parseJobs(data)

    func isinvalid(_ job: [Int]) -> Bool {
        for (i, x) in job.enumerated() {
            if let ps = rules[x] {
                for p in ps {
                    if job[0..<i].contains(p) {
                        return true
                    }
                }
            }
        }
        return false
    }

    func valid(_ job: [Int]) -> Int {
        var res: [Int] = []
        var remain = Set(job)
        for x in job {
            if let ps = rules[x] {
                var i = res.count
                for p in ps {
                    if let j = res.firstIndex(of: p) {
                        i = min(i, j)
                    }
                }
                res.insert(x, at: i)
                remain.remove(x)
            }
        }
        res.append(contentsOf: remain)
        return res[res.count / 2]
    }

    return jobs.filter(isinvalid).map(valid).reduce(0, +)
}


let test1 = """
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
"""
assert(part1(test1) == 143)
assert(part2(test1) == 123)


let data = try! String(contentsOfFile: "day5.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
