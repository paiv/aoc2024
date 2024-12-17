#!/usr/bin/env swift
import Foundation


struct Image {
    var ra: Int
    var rb: Int
    var rc: Int
    var ip: Int
}


func vm_parse(_ data: String) -> ([Int], Image) {
    let regs = data.matches(of: #/[ABC]: (\d+)/#).map { Int($0.1)! }
    let prog = data.split(separator: "Program:").last!
        .matches(of: #/\d+/#).map { Int($0.0)! }
    let image = Image(ra: regs[0], rb: regs[1], rc: regs[2], ip: 0)
    return (prog, image)
}


func vm_run(_ prog: [Int], _ vm: Image) -> [Int] {
    let pn = prog.count
    var regs = [vm.ra, vm.rb, vm.rc]
    let (ra, rb, rc) = (4, 5, 6)
    var output: [Int] = []
    var ip = vm.ip

    func _arg(_ v: Int) -> Int {
        switch v {
            case 4, 5, 6:
                return regs[v - 4]
            default:
                return v
        }
    }

    func _set(_ r: Int, _ v: Int) {
        regs[r - 4] = v
    }

    while ip >= 0 && ip + 1 < pn {
        let op = prog[ip]
        let val = _arg(prog[ip + 1])

        switch op {
            case 0:
                _set(ra, _arg(ra) >> val)
                ip += 2
            case 1:
                _set(rb, _arg(rb) ^ val)
                ip += 2
            case 2:
                _set(rb, val % 8)
                ip += 2
            case 3:
                if _arg(ra) != 0 {
                    ip = val
                }
                else {
                    ip += 2
                }
            case 4:
                _set(rb, _arg(rb) ^ _arg(rc))
                ip += 2
            case 5:
                output.append(val % 8)
                ip += 2
            case 6:
                _set(rb, _arg(ra) >> val)
                ip += 2
            case 7:
                _set(rc, _arg(ra) >> val)
                ip += 2
            default:
                fatalError("unhandled op \(op) \(val)")
        }
    }

    return output
}


func part1(_ data: String) -> String {
    let (prog, vm) = vm_parse(data)
    let res = vm_run(prog, vm)
    let ans = res.map(String.init).joined(separator: ",")
    return ans
}


func part2(_ data: String) -> Int {
    let (prog, vm) = vm_parse(data)

    func shx(_ v: Int, _ i: Int) -> Int {
        let a = ((v << 3) | i) >> (i ^ 3)
        return (a % 8) ^ i
    }

    func reverse(_ k: Int, _ acc: Int) -> [Int] {
        if k < 0 {
            [acc]
        }
        else {
            (0..<8).flatMap { i in
                shx(acc, i) == prog[k] ?
                    reverse(k - 1, (acc << 3) | i) : []
            }
        }
    }

    for ans in reverse(prog.count - 1, 0) {
        var vm = vm
        vm.ra = ans
        if vm_run(prog, vm) == prog {
            return ans
        }
    }
    fatalError()
}


let test = """
Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0
"""
assert(part1(test) == "4,6,3,5,6,3,5,2,1,0")


let data = try! String(contentsOfFile: "day17.in", encoding: .utf8)
let ans1 = part1(data)
print("part1: \(ans1)")
let ans2 = part2(data)
print("part2: \(ans2)")
