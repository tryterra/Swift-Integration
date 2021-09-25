//
//  Samples.swift
//  Terra
//
//  Created by Elliott Yu on 24/09/2021.
//

import Foundation
import HealthKit

class SamplesData{
    var healthStore: HKHealthStore?
    init(){
        self.healthStore = HealthStore().healthStore
    }
    
    func getHeartRates() -> [HeartRate]{
        var heartRates: [HeartRate] = [HeartRate]()
        let calendar = NSCalendar.current
        let endDate = Date()
        
        var heartRateQuery: HKQuantitySeriesSampleQuery?
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        
        guard let startDate = calendar.date(byAdding: .day, value: -1, to: endDate) else {
            fatalError("Cannot Create StartDate")
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        
        func sampleHeartRateDataHandler(query: HKQuantitySeriesSampleQuery, quantity: HKQuantity?, interval: DateInterval?, sample: HKQuantitySample?, done: Bool, error: Error?) -> Void {
            
            if let error = error {
                print(error)
            }
            guard let quantity = quantity else {
                fatalError("Cannot get data")
            }
            let bpm = quantity.doubleValue(for: HKUnit.hertzUnit(with: .milli))*60/1000
            let time = interval
            heartRates.append(HeartRate(timestamp: time!.start, bpm: Int(bpm)))
        }
        
        heartRateQuery = HKQuantitySeriesSampleQuery(quantityType: heartRateType, predicate: predicate, quantityHandler: sampleHeartRateDataHandler(query:quantity:interval:sample:done:error:))
        
        if let healthStore = self.healthStore,
           let heartRateQuery = heartRateQuery{
            healthStore.execute(heartRateQuery)
            }
        
        return heartRates
    }
    
    func getHeartRateHRV() -> [HRV] {
        var heartRateHRV: [HRV] = [HRV]()
        
        let calendar = NSCalendar.current
        let endDate = Date()
        
        var hrvQuery: HKQuantitySeriesSampleQuery?
        let heartRateVarType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)!
        
        
        guard let startDate = calendar.date(byAdding: .day, value: -1, to: endDate) else {
            fatalError("Cannot Create StartDate")
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        func sampleHRVDataHandler(query: HKQuantitySeriesSampleQuery, quantity: HKQuantity?, interval: DateInterval?, sample: HKQuantitySample?, done: Bool, error: Error?) -> Void {

            if let error = error {
                print(error)
            }
            guard let quantity = quantity else {
                fatalError("Cannot get data")
            }
            let sdnn = quantity.doubleValue(for: .secondUnit(with: .milli))
            let time = interval
            heartRateHRV.append(HRV(sdnn: sdnn, timestamp: time!.start))
        }
        
        hrvQuery = HKQuantitySeriesSampleQuery(quantityType: heartRateVarType, predicate: predicate, quantityHandler:  sampleHRVDataHandler(query:quantity:interval:sample:done:error:))
        
        if let healthStore = self.healthStore,
           let hrvQuery = hrvQuery{
            healthStore.execute(hrvQuery)
        }
        return heartRateHRV
    }
    
}
