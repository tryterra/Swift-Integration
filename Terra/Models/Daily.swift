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
    
    mutating func setActivitySummary(summary: ActivitySummary){
        self.activitySummary = summary
    }
    
    mutating func setHRV(HRV: [HRV]){
        self.hrv = HRV
    }
    
    mutating func setHeartRates(hr: [HeartRate]){
        self.heartRates = hr
    }
    
    mutating func setWalkingDistance(distance: Double){
        self.walkingOrRunningDistance = distance
    }
    
    mutating func setSteps(steps:Int){
        self.steps = steps
    }
    
    mutating func setFloors(floors:Int){
        self.floorsClimbed = floors
    }
    
    mutating func setCycling(distance: Double){
        self.cyclingDistance = distance
    }
    
    mutating func setSwimmingDistance(distance: Double){
        self.swimmingDistance = distance
    }
    
    
}
