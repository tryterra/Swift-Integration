//
//  BodyData.swift
//  Terra
//
//  Created by Elliott Yu on 27/09/2021.
//

import Foundation
import HealthKit

class BodyData{
    
    var body: Body
    var healthStore: HealthStore?
    var bmi: Double
    var saturation: Double
    var heightCm: Double
    var weightKg: Double
    var bodyFatPercentage: Double
    var oxygenSat: Double
    var hrVar: Double
    var bpSys: Int
    var bpDia: Int
    var bodyTemp: Double
    var leanMuscleKg: Double
    
    init(){
        self.body = Body()
        self.healthStore = HealthStore()
        self.bmi = Double()
        self.saturation = Double()
        self.heightCm = Double()
        self.weightKg = Double()
        self.bodyFatPercentage = Double()
        self.oxygenSat = Double()
        self.hrVar = Double()
        self.bpSys = Int()
        self.bpDia = Int()
        self.bodyTemp = Double()
        self.leanMuscleKg = Double()
    }
    
    func getBody(completion: @escaping () -> Void){
    
        let calendar = NSCalendar.current
        let endDate = Date()
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "terra.body.queue")

        guard let startDate = calendar.date(byAdding: .day, value: -1, to: endDate) else {
            fatalError("Unable to create the start date")
        }
        
        group.enter()
        queue.async(group: group){ [self] in
            
            group.leave()
        }
        
//        group.notify(queue: queue){
//            self.body = Body(bmi: <#T##Double#>, oxygenSaturation: <#T##Double#>, heightCm: <#T##Double#>, weightKg: <#T##Double#>, bodyFatPercentage: <#T##Double#>, oxygenSat: <#T##Double#>, hrVar: <#T##Double#>, bpSys: <#T##Int#>, bpDia: <#T##Int#>, bodyTemp: <#T##Double#>, leanMuscleKg: <#T##Double#>)
//
//            completion()
//        }
    }
    
    func getBmi(startDate: Date, endDate: Date, completion: @escaping () -> Void){
        var bmiQuery: HKStatisticsCollectionQuery?
        let bmiType = HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!
        
        let quantPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        bmiQuery = HKStatisticsCollectionQuery(quantityType: bmiType, quantitySamplePredicate: quantPredicate, options: .discreteAverage, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        bmiQuery!.initialResultsHandler = { query, result, error in
            if let error = error {
                print(error)
            }
            guard let bmi = result else{
                fatalError("Cannot get BMI data")
            }
            
            bmi.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                self.bmi = statistics.averageQuantity()?.doubleValue(for: .count()) ?? 0.0
                completion()
            }
        }
        if let healthStore = self.healthStore?.healthStore, let bmiQuery = bmiQuery {
            healthStore.execute(bmiQuery)
        }
    }
    
    func getOxygenSat(startDate: Date, endDate: Date, completion: @escaping() -> Void){
        var oxygenSatQuery: HKStatisticsCollectionQuery?
        let oxygenSatType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        oxygenSatQuery = HKStatisticsCollectionQuery(quantityType: oxygenSatType, quantitySamplePredicate: predicate, options: .discreteAverage, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        oxygenSatQuery!.initialResultsHandler = { query, result, error in
            if let error = error {
                print(error)
            }
            guard let oxygenSat = result else{
                fatalError("Cannot get oxygen saturation data")
            }
            
            oxygenSat.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                self.oxygenSat = statistics.averageQuantity()?.doubleValue(for: .percent()) ?? 0.0
                completion()
            }
        }
    }
    
    func getHeight(startDate: Date, endDate: Date, completion: @escaping() -> Void){
        var heightQuery: HKStatisticsCollectionQuery?
        let heightType = HKObjectType.quantityType(forIdentifier: .height)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        heightQuery = HKStatisticsCollectionQuery(quantityType: heightType, quantitySamplePredicate: predicate, anchorDate: Date.mondayAt12AM(), intervalComponents: DateComponents(day: 1))
        
        heightQuery!.initialResultsHandler = {query, result, error in
            if let error = error {
                print(error)
            }
            guard let height = result else{
                fatalError("Cannot retrieve height data")
            }
            height.enumerateStatistics(from: startDate, to: endDate){(statistics, stop) in
                self.heightCm = statistics.averageQuantity()?.doubleValue(for: .meterUnit(with: .centi)) ?? 0.0
                completion()
            }
        }
        
        if let healthStore = self.healthStore?.healthStore, let heightQuery = heightQuery{
            healthStore.execute(heightQuery)
        }
    }

    
    
}
