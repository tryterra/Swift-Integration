//
//  Daily.swift
//  Terra
//
//  Created by Elliott Yu on 24/09/2021.
//

import Foundation
import HealthKit
import UIKit

class DailyData {
    var healthStore: HealthStore?
    var daily: Daily
    var walkDistance: Double
    var cycleDistance: Double
    var swimDistance: Double
    var totalSteps: Int
    var floorsClimbed: Int
    var basalEnergy: Double
    var vo2Max: Double
    var swimCount: Int
    var activitySummary: ActivitySummary
    
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
        self.vo2Max = Double()
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
        
        samples.getHeartRateHRV(group: group, queue: queue, completion: {(HRV) -> Void in
            self.daily.setHRV(HRV: HRV)
        })

        samples.getHeartRates(group: group, queue: queue, completion: {(hr) -> Void in
            self.daily.setHeartRates(hr: hr)
        })
        
        group.enter()
        queue.async(group: group){ [self] in
            group.enter()
            getWalkingDistance(startDate: startDate, endDate: endDate, completion: {() -> Void in
                group.leave()
            })
            group.enter()
            getCyclingDistance(startDate: startDate, endDate: endDate, completion:  {() -> Void in
                group.leave()
            })
            group.enter()
            getSwimmingDistance(startDate: startDate, endDate: endDate, completion:  {() -> Void in
                group.leave()
            })
            group.enter()
            getSteps(startDate: startDate, endDate: endDate, completion: {() -> Void in
                group.leave()
            })
            group.enter()
            getFloorsClimbed(startDate: startDate, endDate: endDate, completion: {() -> Void in
                group.leave()
            })
            group.enter()
            getActivitySummary(startDate: startDate, endDate: endDate, completion:  {() ->  Void in
                group.leave()
            })
            group.enter()
            getBasalEnergy(startDate: startDate, endDate: endDate, completion:  {() ->  Void in
                group.leave()
            })
            group.enter()
            getSwimStroke(startDate: startDate, endDate: endDate, completion:  {() ->  Void in
                group.leave()
            })
            group.leave()
        }
        
        group.notify(queue: queue){
            completion()
        }
    }
    
    func getSteps(startDate: Date, endDate: Date, completion: @escaping ()-> Void) {
        var stepsQuery: HKStatisticsCollectionQuery?
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let samplePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        stepsQuery = HKStatisticsCollectionQuery(quantityType: stepsType, quantitySamplePredicate: samplePredicate, options: .cumulativeSum, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        stepsQuery!.initialResultsHandler = {query, distances, error in
            if let error = error {
                print(error)
            }
            guard let distances = distances else{
                fatalError("Cannot get steps distance data")
            }
            distances.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                if let quantity = statistics.sumQuantity(){
                    self.totalSteps = Int(quantity.doubleValue(for: .count()))
                    self.daily.setSteps(steps: self.totalSteps)
                    completion()
                }
            }
        }
        
        if let healthStore = self.healthStore?.healthStore, let stepsQuery = stepsQuery {
            healthStore.execute(stepsQuery)
        }
    }
    
    func getFloorsClimbed(startDate: Date, endDate: Date, completion: @escaping () -> Void) {
        var floorsQuery: HKStatisticsCollectionQuery?
        let floorsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        
        let samplePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        floorsQuery = HKStatisticsCollectionQuery(quantityType: floorsType, quantitySamplePredicate: samplePredicate, options: .cumulativeSum, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        floorsQuery!.initialResultsHandler = {query, distances, error in
            if let error = error {
                print(error)
            }
            guard let distances = distances else{
                fatalError("Cannot get floors distance data")
            }
            
            distances.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                if let quantity = statistics.sumQuantity(){
                    self.floorsClimbed = Int(quantity.doubleValue(for: .count()))
                    self.daily.setFloors(floors: self.floorsClimbed)
                    completion()
                }
            }
        }
        if let healthStore = self.healthStore?.healthStore, let floorsQuery = floorsQuery {
            healthStore.execute(floorsQuery)
        }
    }
    
    
    func getWalkingDistance(startDate: Date, endDate: Date, completion: @escaping ()-> Void) {
        var walkDistanceQuery: HKStatisticsCollectionQuery?
        let walkDistanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        
        let samplePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        walkDistanceQuery = HKStatisticsCollectionQuery(quantityType: walkDistanceType, quantitySamplePredicate: samplePredicate, options: .cumulativeSum, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        walkDistanceQuery!.initialResultsHandler = {query, distances, error in
            if let error = error {
                print(error)
            }
            guard let distances = distances else{
                fatalError("Cannot get walk distance data")
            }
            distances.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                self.walkDistance = (statistics.sumQuantity()?.doubleValue(for: .meterUnit(with: .none))) ?? 0.0
                self.daily.setWalkingDistance(distance: self.walkDistance)
                completion()
            }
        }
        if let healthStore = self.healthStore?.healthStore, let walksDistanceQuery = walkDistanceQuery {
            healthStore.execute(walksDistanceQuery)
        }
    }
    
    func getCyclingDistance(startDate: Date, endDate: Date, completion: @escaping () -> Void) {
        var cycleDistanceQuery: HKStatisticsCollectionQuery?
        let cycleDistanceType = HKQuantityType.quantityType(forIdentifier: .distanceCycling)!
        
        let samplePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        cycleDistanceQuery = HKStatisticsCollectionQuery(quantityType: cycleDistanceType, quantitySamplePredicate: samplePredicate, options: .cumulativeSum, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        cycleDistanceQuery!.initialResultsHandler = {query, distances, error in
            if let error = error {
                print(error)
            }
            guard let distances = distances else{
                fatalError("Cannot get cycling distance data")
            }
            distances.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                self.cycleDistance = (statistics.sumQuantity()?.doubleValue(for: .meterUnit(with: .none))) ?? 0.0
                self.daily.setCycling(distance: self.cycleDistance)
            }
        }
        if let healthStore = self.healthStore?.healthStore, let cycleDistanceQuery = cycleDistanceQuery {
            healthStore.execute(cycleDistanceQuery)
        }
    }
    
    func getSwimmingDistance(startDate: Date, endDate: Date, completion: @escaping () -> Void) {
        var swimDistanceQuery: HKStatisticsCollectionQuery?
        let swimDistanceType = HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!
        
        let samplePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        swimDistanceQuery = HKStatisticsCollectionQuery(quantityType: swimDistanceType, quantitySamplePredicate: samplePredicate, options: .cumulativeSum, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        swimDistanceQuery!.initialResultsHandler = {query, distances, error in
            if let error = error {
                print(error)
            }
            guard let distances = distances else{
                fatalError("Cannot get swimming distance data")
            }
            distances.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                self.swimDistance = (statistics.sumQuantity()?.doubleValue(for: .meterUnit(with: .none))) ?? 0.0
                self.daily.setSwimmingDistance(distance: self.swimDistance)
                completion()
            }
        }
        if let healthStore = self.healthStore?.healthStore, let swimDistanceQuery = swimDistanceQuery {
            healthStore.execute(swimDistanceQuery)
        }
    }
    
    
    func getActivitySummary (startDate: Date, endDate: Date, completion: @escaping() -> Void) {
        let calendar = NSCalendar.current
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
                let energy   = summary.activeEnergyBurned.doubleValue(for: HKUnit.kilocalorie())
                let stand    = summary.appleStandHours.doubleValue(for: HKUnit.count())
                let exercise = summary.appleExerciseTime.doubleValue(for: HKUnit.second())
                self.activitySummary = ActivitySummary(date: endDate, energy: energy, standSeconds: stand, exerciseSeconds: exercise)
                self.daily.setActivitySummary(summary: self.activitySummary)
                completion()
            }
        }
        if let healthStore = self.healthStore?.healthStore, let summaryQuery = summaryQuery {
            healthStore.execute(summaryQuery)
        }
    }
    
    func getVo2Max(startDate: Date, endDate: Date, completion: @escaping () -> Void) {
        var vo2MaxQuery: HKStatisticsCollectionQuery?
        let vo2MaxType = HKQuantityType.quantityType(forIdentifier: .vo2Max)!
        
        let samplePredicate = HKQuery.predicateForSamples(withStart: startDate, end:endDate, options: .strictStartDate)
        
        vo2MaxQuery = HKStatisticsCollectionQuery(quantityType: vo2MaxType, quantitySamplePredicate: samplePredicate, options: .cumulativeSum, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        vo2MaxQuery!.initialResultsHandler = {query, result, error in
            if let error = error {
                print(error)
            }
            guard let vo2max = result else{
                fatalError("Cannot get vo2max")
            }
            vo2max.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                self.vo2Max = statistics.sumQuantity()?.doubleValue(for: HKUnit.literUnit(with: .milli).unitDivided(by: HKUnit.gramUnit(with: .kilo).unitDivided(by: HKUnit.minute()))) ?? 0.0
                completion()
            }
        }
        if let healthStore = self.healthStore?.healthStore, let vo2MaxQuery = vo2MaxQuery {
            healthStore.execute(vo2MaxQuery)
        }
        
    }
    
    func getBasalEnergy(startDate: Date, endDate: Date, completion: @escaping () -> Void) {
        var basalEnergyQuery: HKStatisticsCollectionQuery?
        let basalEnergyType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!
        
        let samplePredicate = HKQuery.predicateForSamples(withStart: startDate, end:endDate, options: .strictStartDate)
        
        basalEnergyQuery = HKStatisticsCollectionQuery(quantityType: basalEnergyType, quantitySamplePredicate: samplePredicate, options: .cumulativeSum, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        basalEnergyQuery!.initialResultsHandler = {query, result, error in
            if let error = error {
                print(error)
            }
            guard let basalEnergy = result else{
                fatalError("Cannot get vo2max")
            }
            basalEnergy.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                self.basalEnergy = statistics.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0
                self.daily.setBasalEnergy(energy: self.basalEnergy)
                completion()
            }
        }
        if let healthStore = self.healthStore?.healthStore, let basalEnergyQuery = basalEnergyQuery {
            healthStore.execute(basalEnergyQuery)
        }
    }
    
    func getSwimStroke(startDate: Date, endDate: Date, completion: @escaping () -> Void) {
        var swimStrokeQuery: HKStatisticsCollectionQuery?
        let swimStrokeType = HKQuantityType.quantityType(forIdentifier: .swimmingStrokeCount)!
        
        let samplePredicate = HKQuery.predicateForSamples(withStart: startDate, end:endDate, options: .strictStartDate)
        
        swimStrokeQuery = HKStatisticsCollectionQuery(quantityType: swimStrokeType, quantitySamplePredicate: samplePredicate, options: .cumulativeSum, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        swimStrokeQuery!.initialResultsHandler = {query, result, error in
            if let error = error {
                print(error)
            }
            guard let swimStroke = result else{
                fatalError("Cannot get swim stroke counts")
            }
            swimStroke.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                self.swimCount = Int(statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)
                self.daily.setSwimCount(count: self.swimCount)
                completion()
            }
        }
        if let healthStore = self.healthStore?.healthStore, let swimStrokeQuery = swimStrokeQuery {
            healthStore.execute(swimStrokeQuery)
        }
    }
    
}
