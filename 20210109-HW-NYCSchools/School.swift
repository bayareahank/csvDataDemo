//
//  School.swift
//  
//  Created by bayareahank on 1/9/22.
//

import Foundation

// Would use this as index in the score dictionary
enum TestItem: String {
    case writing = "Writing"
    case math    = "Math"
    case reading = "Reading"
}

struct TestScore {
    var test: TestItem
    var value: String
}

// Main element of data body
struct School {
    var name: String
    var description: String = ""
    
    var scores: [TestItem:TestScore] = [
        .writing: TestScore(test: .writing, value: "s"),
        .reading: TestScore(test: .reading, value: "s"),
        .math: TestScore(test: .math, value: "s")]
    // We use string as value type, cause it could be missing at times -- 's'
}


