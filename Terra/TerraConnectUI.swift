//
//  TerraConnectUI.swift
//  Terra
//
//  Created by Elliott Yu on 23/09/2021.
//

import Foundation
import SwiftUI

struct TerraConnectUI: View{
    let title = "Connect Terra"
    var dev_id: String
    
    @Environment(\.isEnabled) private var isEnabled
    
    var body: some View{
        Button(title, action: connectToTerra)
            .foregroundColor(.white)
            .padding()
            .background(Color.accentColor)
            .cornerRadius(8)
    }
 
    func connectToTerra() {
        let url = URL(string: "http://localhost:5000/auth/apple/connect")
        guard let requestUrl = url else {fatalError()}
            
        var request = URLRequest(url: requestUrl)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(dev_id, forHTTPHeaderField: "dev-id")
        
        let formatter = ISO8601DateFormatter()
        let now = formatter.string(from: Date())
        let postString = "time_created=\(now)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
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
}

