//
//  Activity.swift
//  Terra
//
//  Created by Elliott Yu on 23/09/2021.
//

import Foundation

struct Step: Codable {
    let count: Int
    let timestamp: Date
}

struct Activity: Codable {
    var summary: ActivitySummary
    var samples: Samples    
}

struct ActivitySummary: Codable{
    var date: Date = Date()
    var energy: Double = Double()
    var standSeconds: Double = Double()
    var exerciseSeconds: Double = Double()
}
