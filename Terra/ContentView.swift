//
//  ContentView.swift
//  Terra
//
//  Created by Elliott Yu on 23/09/2021.
//

import SwiftUI
import CoreData
import HealthKit
import WebKit
import UIKit
import Combine
import TerraSwift


struct TerraWidgetSessionCreateResponse:Decodable{
    var status: String = String()
    var url: String = String()
    var session_id: String = String()
}

extension Date {
    static func todayAt12AM(date: Date) -> Date{
        return Calendar(identifier: .iso8601).startOfDay(for: date)
    }
}

func getSessionId() -> String{
    let session_url = URL(string: "https://api.tryterra.co/v2/auth/generateWidgetSession")
    var url = ""
    var request = URLRequest(url: session_url!)
    let requestData = ["reference_id": "testing", "providers" : "APPLE", "auth_success_redirect_url": "www.tryterra.co", "auth_failure_redirect_url": "www.google.com", "language": "EN"]
    let group = DispatchGroup()
    let queue = DispatchQueue(label: "widget.Terra")
    let jsonData = try? JSONSerialization.data(withJSONObject: requestData)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(DEVID, forHTTPHeaderField: "dev-id")
    request.setValue(XAPIKEY, forHTTPHeaderField: "X-API-Key")
    request.httpBody = jsonData
    let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
        if let data = data{
            let decoder = JSONDecoder()
            do{
                let result = try decoder.decode(TerraWidgetSessionCreateResponse.self, from: data)
                url = result.url
                group.leave()
            }
            catch{
                print(error)
            }
        }
    }
    group.enter()
    queue.async(group:group) {
        task.resume()
    }
    group.wait()
    return url
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
        
    
    private var items: FetchedResults<Item>
    
    @State private var startDaily: Date = Date.todayAt12AM(date:Date())
    @State private var endDaily: Date = Date()

    @State private var startSleep: Date = Date.todayAt12AM(date:Date())
    @State private var endSleep: Date = Date()
    
    @State private var startBody: Date = Date.todayAt12AM(date:Date())
    @State private var endBody: Date = Date()
    
    @State private var startActivity: Date = Date.todayAt12AM(date:Date())
    @State private var endActivity: Date = Date()
    
        
    @ObservedObject var widget = WebViewTerra(url: getSessionId())

    var body: some View {
        let webview = TerraWidget(webViewTerra: widget)
        ZStack{
            Group{
                webview.zIndex(1)
                if webview.widget.authenticated == true {
                    Group{
                        Text("Hello from Terra").padding(.all).position(x: 190, y: 40)
                        VStack{
                            Button("Test Athlete", action: {
                                widget.TerraClient?.getAthlete()
                            }).foregroundColor(.white).padding().background(Color.accentColor).cornerRadius(8)
                            HStack{
                                Button("Test Daily", action:{
                                    widget.TerraClient?.getDaily(startDate: startDaily, endDate: endDaily)
                                }).foregroundColor(.white).padding().background(Color.accentColor).cornerRadius(8)
                                VStack{
                                    Group{
                                        DatePicker("Start Date", selection: $startDaily, displayedComponents: [.date])
                                        DatePicker("End Date", selection: $endDaily, displayedComponents: [.date])
                                    }
                                }
                            }.padding(.bottom).padding(.top)
                            HStack{
                                Button("Test Body", action:{
                                    widget.TerraClient?.getBody(startDate: startBody, endDate: endBody)
                                }).foregroundColor(.white).padding().background(Color.accentColor).cornerRadius(8)
                                VStack{
                                    Group{
                                        DatePicker("Start Date", selection: $startBody, displayedComponents: [.date, ])
                                        DatePicker("End Date", selection: $endBody, displayedComponents: [.date, ])
                                    }
                                }
                            }.padding(.bottom)
                            HStack{
                                Button("Test Sleep", action:{
                                    widget.TerraClient?.getSleep(startDate: startSleep, endDate: endSleep)
                                }).foregroundColor(.white).padding().background(Color.accentColor).cornerRadius(8)
                                VStack{
                                    Group{
                                        DatePicker("Start Date", selection: $startSleep, displayedComponents: [.date])
                                        DatePicker("End Date", selection: $endSleep, displayedComponents: [.date])
                                    }
                                }
                            }.padding(.bottom)
                            
                            HStack{
                                Button("Test Activity", action:{
                                    widget.TerraClient?.getWorkout(startDate: startActivity, endDate: endActivity)
                                }).foregroundColor(.white).padding().background(Color.accentColor).cornerRadius(8)
                                VStack{
                                    Group{
                                        DatePicker("Start Date", selection: $startActivity, displayedComponents: [.date])
                                        DatePicker("End Date", selection: $endActivity, displayedComponents: [.date])
                                    }
                                }
                            }.padding(.bottom)
                        }.zIndex(2)
                    }
                }
            }
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
