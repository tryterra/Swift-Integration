//
//  Athlete.swift
//  Terra
//
//  Created by Elliott Yu on 24/09/2021.
//

import Foundation
import HealthKit

class AthleteData{
    
    var healthStore: HKHealthStore?
    init(){
        self.healthStore = HealthStore().healthStore
    }
    
    func athleteData() -> Athlete? {
        if let healthStore = healthStore {
            let username = NSUserName()
            var dateOfBirth: String
            var gender: String
            if try! healthStore.biologicalSex().biologicalSex == HKBiologicalSex.female {
                gender = "Female"
            }
            else if try! healthStore.biologicalSex().biologicalSex == HKBiologicalSex.male{
                gender = "Male"
            }
            else {gender = "None"}
            if try! healthStore.dateOfBirthComponents().date != nil {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                dateOfBirth = formatter.string(from: try! healthStore.dateOfBirthComponents().date!)
            }
            else{
                dateOfBirth = "None"
            }
            return Athlete(dateOfBirth: dateOfBirth, gender: gender, username: username)
        }
        return nil
    }
    
}
