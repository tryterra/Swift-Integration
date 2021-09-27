//
//  Daily.swift
//  Terra
//
//  Created by Elliott Yu on 24/09/2021.
//

import Foundation

struct Daily: Codable{
    var activitySummary: ActivitySummary? = ActivitySummary()
    var hrv: [HRV] = [HRV]()
    var heartRates: [HeartRate] = [HeartRate]()
    var walkingOrRunningDistance: Double = Double()
    var steps: Int = Int()
    var floorsClimbed: Int = Int()
    var swimmingDistance: Double = Double()
    var cyclingDistance: Double = Double()
    var basalEnergy: Double = Double()
    var swimCount: Int = Int()
    var restingHr: Int = Int()
    
    mutating func setActivitySummary(summary: ActivitySummary){
        self.activitySummary = summary
    }
    
    mutating func setHRV(HRV: [HRV]){
        self.hrv = HRV
    }
    
    mutating func setHeartRates(hr: [HeartRate]){
        self.heartRates = hr
    }
    
}
