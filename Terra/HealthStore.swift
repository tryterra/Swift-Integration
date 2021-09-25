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
                                                 ])
        
        guard let healthStore = self.healthStore else {return completion(false)}
        healthStore.requestAuthorization(toShare: nil, read: readAllType){(success, error) in completion(success)}

    }
    
}
