
//
//  Samples.swift
//  Terra
//
//  Created by Elliott Yu on 24/09/2021.
//
import Foundation
import HealthKit

class SamplesData{
    var healthStore: HealthStore?
    init(){
        self.healthStore = HealthStore()
    }
    
    func getHeartRates(completion: @escaping ([HeartRate]) -> Void){
        
        let groupHr = DispatchGroup()
        let queueHr = DispatchQueue(label: "terra.hr")
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
            
            if done == true {
                groupHr.leave()
            }
        }
        
        heartRateQuery = HKQuantitySeriesSampleQuery(quantityType: heartRateType, predicate: predicate, quantityHandler: sampleHeartRateDataHandler(query:quantity:interval:sample:done:error:))
        
        if let healthStore = self.healthStore?.healthStore,
           let heartRateQuery = heartRateQuery{
            groupHr.enter()
                queueHr.async(group:groupHr) {
                    groupHr.enter()
                    healthStore.execute(heartRateQuery)
                    groupHr.leave()
                }
            }
        groupHr.notify(queue: queueHr){
            completion(heartRates)
        }
    }
    
    func getHeartRateHRV(completion: @escaping ([HRV]) -> Void){
        
        let groupHrv = DispatchGroup()
        let queueHrv = DispatchQueue(label: "terra.hrv")
        
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
            
            if done == true {
                groupHrv.leave()
            }
        }
        
        hrvQuery = HKQuantitySeriesSampleQuery(quantityType: heartRateVarType, predicate: predicate, quantityHandler:  sampleHRVDataHandler(query:quantity:interval:sample:done:error:))
        
        if let healthStore = self.healthStore?.healthStore,
           let hrvQuery = hrvQuery{
            groupHrv.enter()
                queueHrv.async(group:groupHrv) {
                    groupHrv.enter()
                    healthStore.execute(hrvQuery)
                    groupHrv.leave()
                }
            }
        
        groupHrv.notify(queue: queueHrv){
            completion(heartRateHRV)
        }
    }
    
}
