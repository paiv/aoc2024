#!/usr/bin/env swift
import Foundation


struct V2 : Hashable {
    var x: Int
    var y: Int
}


func part1(_ data: String, N: Int = 100, w: Int = 101, h: Int = 103) -> Int {
    let data = data.matches(of: #/[+-]?\d+/#).map { Int($0.0)! }

    var grid: [V2:Int] = [:]
    for i in stride(from: 0, to: data.count, by: 4) {
        let px = data[i+0]
        let py = data[i+1]
        let vx = data[i+2]
        let vy = data[i+3]
        let x = (px + vx * N) % w
        let y = (py + vy * N) % h
        let p = V2(x: (x + w) % w, y: (y + h) % h)
        grid[p, default: 0] += 1
    }

    let w2 = w / 2
    let h2 = h / 2
    let w2p = w2 + 1
    let h2p = h2 + 1
    var qs: [V2:Int] = [:]

    for (p, n) in grid {
        if p.x == w2 || p.y == h2 {
            continue
        }
        let q = V2(x: p.x / w2p, y: p.y / h2p)
        qs[q, default: 0] += n
    }

    var ans = 1
    for n in qs.values {
        ans *= n
    }
    return ans
}


func part2(_ data: String, w: Int = 101, h: Int = 103) -> Int {
    let data = data.matches(of: #/[+-]?\d+/#).map { Int($0.0)! }

    for t in 1... {
        var grid: [V2:Int] = [:]
        for i in stride(from: 0, to: data.count, by: 4) {
            let px = data[i+0]
            let py = data[i+1]
            let vx = data[i+2]
            let vy = data[i+3]
            let x = (px + vx * t) % w
            let y = (py + vy * t) % h
            let p = V2(x: (x + w) % w, y: (y + h) % h)
            grid[p, default: 0] += 1
        }

        if (grid.values.allSatisfy { $0 == 1 }) {
            for p in grid.keys {
                if ((0..<20).allSatisfy { grid[V2(x: p.x + $0, y: p.y)] != nil }) {
                    return t
                }
            }
        }
    }
    fatalError()
}


let test = """
p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3
"""
assert(part1(test, w: 11, h: 7) == 12)


let data = try! String(contentsOfFile: "day14.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
