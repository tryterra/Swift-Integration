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
        queue.async(group: group){
            
            group.enter()
            self.healthStore?.executeStatisticCollectionQueryAvg(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .bodyMassIndex)!, unit: .count(), completion: { (bmi) in
                self.bmi = bmi
                group.leave()
            })
            
            group.enter()
            self.healthStore?.executeStatisticCollectionQueryAvg(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!, unit: HKUnit.percent(), completion: { (oxygen) in
                self.oxygenSat = oxygen
                group.leave()
            })
            
            group.enter()
            self.healthStore?.executeStatisticCollectionQueryAvg(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .height)!, unit: .meterUnit(with: .centi), completion: { (heightCm) in
                self.heightCm = heightCm
                group.leave()
            })
            
            group.enter()
            self.healthStore?.executeStatisticCollectionQueryAvg(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .bodyMass)!, unit: .gramUnit(with: .kilo), completion: { weightKg in
                self.weightKg = weightKg
                group.leave()
            })
            
            group.enter()
            self.healthStore?.executeStatisticCollectionQueryAvg(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage)!, unit: HKUnit.percent(), completion: { (bodyFat) in
                self.bodyFatPercentage = bodyFat
                group.leave()
            })
            
            group.enter()
            self.healthStore?.executeStatisticCollectionQueryAvg(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!, unit: .secondUnit(with: .milli), completion: { hrv in
                self.hrVar = hrv
                group.leave()
            })
            
            group.enter()
            self.healthStore?.executeStatisticCollectionQueryAvg(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!, unit: HKUnit.millimeterOfMercury(), completion: { bpSys in
                self.bpSys = Int(bpSys)
                group.leave()
            })
            
            group.enter()
            self.healthStore?.executeStatisticCollectionQueryAvg(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!, unit: HKUnit.millimeterOfMercury(), completion: { bpDia in
                self.bpDia = Int(bpDia)
                group.leave()
            })
            
            group.enter()
            self.healthStore?.executeStatisticCollectionQueryAvg(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!, unit: HKUnit.degreeCelsius(), completion: { temp in
                self.bodyTemp = temp
                group.leave()
            })

            group.enter()
            self.healthStore?.executeStatisticCollectionQueryAvg(startDate: startDate, endDate: endDate, quantityType: HKQuantityType.quantityType(forIdentifier: .leanBodyMass)!, unit: HKUnit.gramUnit(with:.kilo), completion: { muscleMass in
                self.leanMuscleKg = muscleMass
                group.leave()
            })
            group.leave()
        }
        
        group.notify(queue: queue){
            self.body = Body(bmi: self.bmi, oxygenSaturation: self.oxygenSat, heightCm: self.heightCm, weightKg: self.weightKg, bodyFatPercentage: self.bodyFatPercentage, hrVar: self.hrVar, bpSys: self.bpSys, bpDia: self.bpDia, bodyTemp: self.bodyTemp, leanMuscleKg: self.leanMuscleKg)
            completion()
        }
    }
    
    
}
