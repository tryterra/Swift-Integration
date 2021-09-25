//
//  Daily.swift
//  Terra
//
//  Created by Elliott Yu on 24/09/2021.
//

import Foundation
import HealthKit

class DailyData {
    var healthStore: HKHealthStore?
    init(){
        self.healthStore = HealthStore().healthStore
    }
    
    func getDaily() -> Daily {
        var daily: Daily

        let calendar = NSCalendar.current
        let endDate = Date()
        
        guard let startDate = calendar.date(byAdding: .day, value: -1, to: endDate) else {
            fatalError("Unable to create the start date")
        }
        let samples: SamplesData = SamplesData()
        let HRV = samples.getHeartRateHRV()
        let heartRates = samples.getHeartRates()
        
        let walkDistance = getWalkingDistance(startDate: startDate, endDate: endDate)
        let cycleDistance = getCyclingDistance(startDate: startDate, endDate: endDate)
        let swimDistance = getSwimmingDistance(startDate: startDate, endDate: endDate)
        let floors = getFloorsClimbed(startDate: startDate, endDate: endDate)
        let steps = getSteps(startDate: startDate, endDate: endDate)
        let activitySummary = getActivitySummary()!
        
        daily = Daily(activitySummary: activitySummary, hrv: HRV, heartRates: heartRates, walkingOrRunningDistance: walkDistance, steps: Int(steps), floorsClimbed: Int(floors), swimmingDistance: swimDistance, cyclingDistance: cycleDistance)
        
        return daily
    }
    
    func getSteps(startDate: Date, endDate: Date) -> Double {
        var steps: Double?
        var stepsQuery: HKStatisticsCollectionQuery?
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let samplePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        stepsQuery = HKStatisticsCollectionQuery(quantityType: stepsType, quantitySamplePredicate: samplePredicate, options: .cumulativeSum, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        stepsQuery?.initialResultsHandler = {query, distances, error in
            if let error = error {
                print(error)
            }
            guard let distances = distances else{
                fatalError("Cannot get walk distance data")
            }
            distances.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                steps = statistics.sumQuantity()?.doubleValue(for: .count())
            }
        }
        return steps ?? 0.0
    }
    
    func getFloorsClimbed(startDate: Date, endDate: Date) -> Double {
        var floors: Double?
        var floorsQuery: HKStatisticsCollectionQuery?
        let floorsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let samplePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        floorsQuery = HKStatisticsCollectionQuery(quantityType: floorsType, quantitySamplePredicate: samplePredicate, options: .cumulativeSum, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        floorsQuery?.initialResultsHandler = {query, distances, error in
            if let error = error {
                print(error)
            }
            guard let distances = distances else{
                fatalError("Cannot get walk distance data")
            }
            distances.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                floors = statistics.sumQuantity()?.doubleValue(for: .count())
            }
        }
        return floors ?? 0.0
    }
    
    
    func getWalkingDistance(startDate: Date, endDate: Date) -> Double {
        var walkDistance: Double?
        var walkDistanceQuery: HKStatisticsCollectionQuery?
        let walkDistanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        
        let samplePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        walkDistanceQuery = HKStatisticsCollectionQuery(quantityType: walkDistanceType, quantitySamplePredicate: samplePredicate, options: .cumulativeSum, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        walkDistanceQuery?.initialResultsHandler = {query, distances, error in
            if let error = error {
                print(error)
            }
            guard let distances = distances else{
                fatalError("Cannot get walk distance data")
            }
            distances.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                walkDistance = statistics.sumQuantity()?.doubleValue(for: .meterUnit(with: .none))
            }
        }
        return walkDistance ?? 0.0
    }
    
    func getCyclingDistance(startDate: Date, endDate: Date) -> Double {
        var cyclingDistance: Double?
        var cycleDistanceQuery: HKStatisticsCollectionQuery?
        let cycleDistanceType = HKQuantityType.quantityType(forIdentifier: .distanceCycling)!
        
        let samplePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        cycleDistanceQuery = HKStatisticsCollectionQuery(quantityType: cycleDistanceType, quantitySamplePredicate: samplePredicate, options: .cumulativeSum, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        cycleDistanceQuery?.initialResultsHandler = {query, distances, error in
            if let error = error {
                print(error)
            }
            guard let distances = distances else{
                fatalError("Cannot get walk distance data")
            }
            distances.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                cyclingDistance = statistics.sumQuantity()?.doubleValue(for: .meterUnit(with: .none))
            }
        }
        return cyclingDistance ?? 0.0
    }
    
    func getSwimmingDistance(startDate: Date, endDate: Date) -> Double {
        var swimmingDistance: Double?
        var swimDistanceQuery: HKStatisticsCollectionQuery?
        let swimDistanceType = HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!
        
        let samplePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        swimDistanceQuery = HKStatisticsCollectionQuery(quantityType: swimDistanceType, quantitySamplePredicate: samplePredicate, options: .cumulativeSum, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        swimDistanceQuery?.initialResultsHandler = {query, distances, error in
            if let error = error {
                print(error)
            }
            guard let distances = distances else{
                fatalError("Cannot get walk distance data")
            }
            distances.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                swimmingDistance = statistics.sumQuantity()?.doubleValue(for: .meterUnit(with: .none))
            }
        }
        return swimmingDistance ?? 0.0
    }
    
    
    func getActivitySummary() -> ActivitySummary? {
        var activitySummary: ActivitySummary?
        let calendar = NSCalendar.current
        let endDate = Date()
        var summaryQuery: HKActivitySummaryQuery?
        
        guard let startDate = calendar.date(byAdding: .day, value: -1, to: endDate) else {
            fatalError("Unable to create the start date")
        }
        let units: Set<Calendar.Component> = [.day, .month, .year]
        
        var startDateComponents = calendar.dateComponents(units, from: startDate)
        startDateComponents.calendar = calendar

        var endDateComponents = calendar.dateComponents(units, from: endDate)
        endDateComponents.calendar = calendar

        let predicate = HKQuery.predicateForActivitySummary(with: startDateComponents)
        
        summaryQuery = HKActivitySummaryQuery(predicate: predicate) {(query, summariesOrNil, errorOrNil) -> Void in
            guard let summaries = summariesOrNil else{
                return
            }
            for summary in summaries{
                print("Hello")
                let energy   = summary.activeEnergyBurned.doubleValue(for: HKUnit.kilocalorie())
                let stand    = summary.appleStandHours.doubleValue(for: HKUnit.count())
                let exercise = summary.appleExerciseTime.doubleValue(for: HKUnit.second())
                
                activitySummary = ActivitySummary(date: endDate, energy: energy, standSeconds: stand, exerciseSeconds: exercise)
            }
        }
        if let healthStore = self.healthStore, let summaryQuery = summaryQuery {
            healthStore.execute(summaryQuery)
        }
        return activitySummary
    }
    
}
