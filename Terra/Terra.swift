//
//  Terra.swift
//  Terra
//
//  Created by Elliott Yu on 23/09/2021.
//

import Foundation
import HealthKit

class Terra{
    let user_id: String
    let dev_id: String
    var healthStore: HealthStore?
    
    init (user_id: String, dev_id: String) {
        self.healthStore = HealthStore()
        self.user_id = user_id
        self.dev_id = dev_id
    }
    
    private func post(data: String, type: String){
        let url = URL(string: "http://localhost:5000/apple/athlete")
        guard let requestUrl = url else {fatalError()}
            
        var request = URLRequest(url: requestUrl)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(self.dev_id, forHTTPHeaderField: "dev-id")
        request.setValue(self.user_id, forHTTPHeaderField: "user-id")
        request.httpBody = data.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            if let error = error{
                print(error)
            }
            if let data = data, let dataString = String(data: data, encoding: .utf8){
                print("Response data : \n \(dataString)")
            }
        }
        task.resume()
        
    }
    
    func getAthleteJson(){
        healthStore?.requestAuthorization(){success in
            if success {
                do {
                    let Athlete: AthleteData = AthleteData()
                    let athlete = Athlete.athleteData()
                    let jsonData = try JSONEncoder().encode(athlete)
                    let jsonString = String(data: jsonData, encoding: .utf8)
                    self.post(data: jsonString ?? "" , type: "athlete")
                } catch {
                    print (error)
                }
            }
        }
    }
    
    func getDaily(){
        healthStore?.requestAuthorization(){success in
            if success {
                do {
                    let Daily: DailyData = DailyData()
                    let daily = Daily.getDaily()
                    let jsonData = try JSONEncoder().encode(daily)
                    let jsonString = String(data: jsonData, encoding: .utf8)
                    self.post(data: jsonString ?? "" , type: "daily")
                } catch {
                    print (error)
                }
            }
        }
    }
    
}

