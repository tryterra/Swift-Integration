//
//  Activity.swift
//  Terra
//
//  Created by Elliott Yu on 23/09/2021.
//

import Foundation

struct Activity: Codable {
    var summary: ActivitySummary
    var heartRates: [HeartRate]
    var hrv: [HRV]
    
}
struct ActivitySummary: Codable{
    var date: Date
    var energy: Double
    var stand: Double
    var exercise: Double
}
