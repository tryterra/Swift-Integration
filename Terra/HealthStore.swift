//
//  HealthStore.swift
//  Terra
//
//  Created by Elliott Yu on 23/09/2021.
//

import Foundation
import HealthKit
import SwiftUI

extension Date {
    static func mondayAt12AM() -> Date{
        return Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!    }
}
class HealthStore{
    var healthStore: HKHealthStore?
    var stepQuery: HKStatisticsCollectionQuery?
        
    init(){
        if HKHealthStore.isHealthDataAvailable(){
            healthStore = HKHealthStore()
        }
    }
    
    func requestAuthorization(completion: @escaping(Bool) -> Void){
        let readAllType: Set<HKObjectType> = Set([HKObjectType.workoutType(),
                                                  HKObjectType.activitySummaryType(),
                                                  HKObjectType.quantityType(forIdentifier:.activeEnergyBurned)!,
                                                  HKQuantityType.quantityType(forIdentifier: .stepCount)!,
                                                  HKObjectType.quantityType(forIdentifier: .heartRate)!,
                                                  HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                                                  HKObjectType.quantityType(forIdentifier: .vo2Max)!,
                                                  HKObjectType.quantityType(forIdentifier: .height)!,
                                                  HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
                                                  HKObjectType.quantityType(forIdentifier: .bodyMass)!,
                                                  HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
                                                  HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
                                                  HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!,
                                                  HKObjectType.quantityType(forIdentifier: .distanceSwimming)!,
                                                  HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                                                  HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                                  HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
                                                  HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
                                                  HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
                                                  HKObjectType.quantityType(forIdentifier: .vo2Max)!,
                                                  HKObjectType.quantityType(forIdentifier: .swimmingStrokeCount)!,
                                                  HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                                                  HKObjectType.quantityType(forIdentifier: .height)!,
                                                  HKObjectType.quantityType(forIdentifier: .bodyMass)!,
                                                  HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
                                                  HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
                                                  HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
                                                  HKObjectType.quantityType(forIdentifier: .leanBodyMass)!,
                                                  HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                                                 ])
        
        guard let healthStore = self.healthStore else {return completion(false)}
        healthStore.requestAuthorization(toShare: nil, read: readAllType){(success, error) in completion(success)}

    }
    
    func executeStatisticCollectionQueryCumSum(startDate: Date, endDate: Date, quantityType: HKQuantityType, unit: HKUnit, group: DispatchGroup, queue: DispatchQueue, completion: @escaping (Double) -> Void){
        
        var query: HKStatisticsCollectionQuery?
        var statResult: Double = Double()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        query!.initialResultsHandler = {query, result, error in
            if let error = error {
                print(error)
            }
            guard let result = result else{
                return
            }
            result.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                statResult = statistics.sumQuantity()?.doubleValue(for: unit) ?? 0.0
            }
            group.leave()

        }
        if let healthStore = healthStore, let query = query{
            group.enter()
            queue.async(group:group) {
                group.enter()
                healthStore.execute(query)
            }
            group.leave()
        }
        group.notify(queue: queue){
            completion(statResult)
        }
    }
    
    func executeStatisticCollectionQueryAvg(startDate: Date, endDate: Date, quantityType: HKQuantityType, unit: HKUnit, group: DispatchGroup, queue: DispatchQueue, completion: @escaping (Double) -> Void){
        
        var query: HKStatisticsCollectionQuery?
        var statResult: Double = Double()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .discreteAverage, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        query!.initialResultsHandler = {query, result, error in
            if let error = error {
                print(error)
            }
            guard let result = result else{
                return
            }
            group.enter()
            result.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                statResult = statistics.averageQuantity()?.doubleValue(for: unit) ?? 0.0
                group.leave()

            }
        }
        if let healthStore = healthStore, let query = query{
            queue.async(group:group) {
                group.enter()
                healthStore.execute(query)
            }
            group.leave()
        }
        group.notify(queue: queue){
            completion(statResult)
        }
    }
    
}
