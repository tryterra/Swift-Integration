//
//  Daily.swift
//  Terra
//
//  Created by Elliott Yu on 24/09/2021.
//

import Foundation
import HealthKit

class DailyData {
    var healthStore: HealthStore?
    var daily: Daily
    var walkDistance: Double
    var cycleDistance: Double
    var swimDistance: Double
    var totalSteps: Int
    var floorsClimbed: Int
    var basalEnergy: Double
    var swimCount: Int
    var activitySummary: ActivitySummary
    var restingHr: Int
    var hr : [HeartRate]
    var hrv: [HRV]
    
    init(){
        self.healthStore = HealthStore()
        self.daily = Daily()
        self.walkDistance = Double()
        self.cycleDistance = Double()
        self.swimDistance = Double()
        self.totalSteps = Int()
        self.floorsClimbed = Int()
        self.basalEnergy = Double()
        self.activitySummary = ActivitySummary()
        self.swimCount = Int()
        self.restingHr = Int()
        self.hr = [HeartRate]()
        self.hrv = [HRV]()
    }

    func getDaily(completion: @escaping ()-> Void) -> Void {
        let calendar = NSCalendar.current
        let endDate = Date()
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "terra.daily.queue")

        guard let startDate = calendar.date(byAdding: .day, value: -1, to: endDate) else {
            fatalError("Unable to create the start date")
        }
        let samples: SamplesData = SamplesData()
        
        group.enter()
        queue.async(group: group) {
            
            group.enter()
            self.healthStore?.executeStatisticCollectionQueryCumSum(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!, unit: HKUnit.meter(),completion: {(walkDist) -> Void in
                self.walkDistance = walkDist
                group.leave()
            })
            group.enter()
            self.healthStore?.executeStatisticCollectionQueryCumSum(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .distanceCycling)!, unit: HKUnit.meter(),  completion: {(cycleDist) -> Void in
                self.cycleDistance = cycleDist
                group.leave()
            })
            group.enter()
            self.healthStore?.executeStatisticCollectionQueryCumSum(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!, unit: HKUnit.meter(),  completion: {(swimDist) -> Void in
                self.swimDistance = swimDist
                group.leave()
            })
            group.enter()
            self.healthStore?.executeStatisticCollectionQueryCumSum(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!, unit: HKUnit.count(), completion: {(steps) -> Void in
                self.totalSteps = Int(steps)
                group.leave()
            })
            group.enter()
            self.healthStore?.executeStatisticCollectionQueryCumSum(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!, unit: HKUnit.count(),completion: {(flights) -> Void in
                self.floorsClimbed = Int(flights)
                group.leave()
            })
            group.enter()
            self.healthStore?.executeStatisticCollectionQueryAvg(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!, unit: HKUnit.hertzUnit(with: .milli), completion: {(hrRest) -> Void in
                self.restingHr = Int(hrRest * 60/1000)
                group.leave()
            })
            group.enter()
            self.healthStore?.executeStatisticCollectionQueryCumSum(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!, unit: HKUnit.kilocalorie(),completion: {(calorie) -> Void in
                self.basalEnergy = calorie
                group.leave()
            })
            group.enter()
            self.healthStore?.executeStatisticCollectionQueryCumSum(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .swimmingStrokeCount)!, unit: HKUnit.count(), completion: {(swimStroke) -> Void in
                self.swimCount = Int(swimStroke)
                group.leave()
            })
            
            group.enter()
            self.getActivitySummary(startDate: startDate, endDate: endDate, completion:  {() ->  Void in
                group.leave()
            })
            
            group.enter()
            samples.getHeartRateHRV(completion: {(HRV) -> Void in
                self.hrv = HRV
                group.leave()
            })
            
            group.enter()
            samples.getHeartRates(completion: {(hr) -> Void in
                self.hr = hr
                group.leave()
            })
            
            group.leave()
        }
        
        group.notify(queue: queue){
            self.daily = Daily(activitySummary: self.activitySummary, hrv: self.hrv, heartRates: self.hr, walkingOrRunningDistance: self.walkDistance, steps: self.totalSteps, floorsClimbed: self.floorsClimbed, swimmingDistance: self.swimDistance, cyclingDistance: self.cycleDistance, basalEnergy: self.basalEnergy, swimCount: self.swimCount, restingHr: self.restingHr)
            completion()
        }
    }
    
    func getActivitySummary (startDate: Date, endDate: Date, completion: @escaping() -> Void) {
        let calendar = NSCalendar.current
        var summaryQuery: HKActivitySummaryQuery?
        
        guard let startDate = calendar.date(byAdding: .day, value: -1, to: endDate) else {
            return
        }
        let units: Set<Calendar.Component> = [.day, .month, .year]
        
        var startDateComponents = calendar.dateComponents(units, from: startDate)
        startDateComponents.calendar = calendar

        var endDateComponents = calendar.dateComponents(units, from: endDate)
        endDateComponents.calendar = calendar

        let predicate = HKQuery.predicateForActivitySummary(with: startDateComponents)
        
        summaryQuery = HKActivitySummaryQuery(predicate: predicate) {(query, summariesOrNil, errorOrNil) -> Void in
            
            if let error = errorOrNil {
                print(error)
            }
            
            guard let summaries = summariesOrNil else{
                return
            }
            
            for summary in summaries{
                let energy   = summary.activeEnergyBurned.doubleValue(for: HKUnit.kilocalorie())
                let stand    = summary.appleStandHours.doubleValue(for: HKUnit.count())
                let exercise = summary.appleExerciseTime.doubleValue(for: HKUnit.second())
                self.activitySummary = ActivitySummary(date: endDate, energy: energy, standSeconds: stand, exerciseSeconds: exercise)
            }
            completion()
        }
        if let healthStore = self.healthStore?.healthStore, let summaryQuery = summaryQuery {
            healthStore.execute(summaryQuery)
        }
    }
    
}
