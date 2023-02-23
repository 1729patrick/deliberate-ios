//
//  main.swift
//  HighSpeedComputation
//
//  Created by Patrick Battisti Forsthofer on 23/02/23.
//

import Accelerate
import Foundation

extension Array {
    init(running function: () -> Element, count: Int) {
        self = (0..<count).map { _ in function() }
    }
}

let count = 10_000_000
let first = Array(running: { Float.random(in: 0...10) }, count: count)
let second = Array(running: { Float.random(in: 0...10) }, count: count)

var start = CFAbsoluteTimeGetCurrent()
var result1: Float = 0.0

for item in first {
    result1 += item
}

var end = CFAbsoluteTimeGetCurrent()
print("1. Took \(end - start) to get \(result1)")

start = CFAbsoluteTimeGetCurrent()
let result2 = first.reduce(0, +)
end = CFAbsoluteTimeGetCurrent()
print("2. Took \(end - start) to get \(result2)")

start = CFAbsoluteTimeGetCurrent()
let result3 = vDSP.sum(first)
end = CFAbsoluteTimeGetCurrent()
print("3. Took \(end - start) to get \(result3)")

//let a = 11111111.11111111
//let b = 22222222.22222222
//let c = 33333333.33333333
//print(a + b + c)
//print(c + b + a)

start = CFAbsoluteTimeGetCurrent()
let value1 = first.max() ?? 0
end = CFAbsoluteTimeGetCurrent()
print("1. Took \(end - start) to find \(value1)")

start = CFAbsoluteTimeGetCurrent()
let value2 = vDSP.maximum(first)
end = CFAbsoluteTimeGetCurrent()
print("2. Took \(end - start) to find \(value2)")

let rms = vDSP.rootMeanSquare(first)

