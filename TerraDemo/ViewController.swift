//
//  ViewController.swift
//  TerraDemo
//
//  Created by Elliott Yu on 21/12/2021.
//

import UIKit
import WebKit
import Foundation
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
    let requestData = ["reference_id": "testing", "providers" : "APPLE", "language": "EN"]
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

var terraClient: Terra? = nil
var userId: String = ""

class MainController: UIViewController {
    
    var startDate = Date.todayAt12AM(date: Date())
    var endDate = Date()
    
    @IBOutlet weak var connect:UIButton!
    
    @IBOutlet weak var disconnect:UIButton!

    @IBOutlet weak var athlete:UIButton!
    
    @IBOutlet weak var body:UIButton!

    @IBOutlet weak var daily:UIButton!

    @IBOutlet weak var sleep:UIButton!
    
    @IBOutlet weak var activity:UIButton!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connect.layer.cornerRadius = 10
        athlete.layer.cornerRadius = 10
        body.layer.cornerRadius = 10
        daily.layer.cornerRadius = 10
        sleep.layer.cornerRadius = 10
        activity.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func athleteAction(_ sender: UIButton){
        terraClient?.getAthlete()
    }
    
    @IBAction func bodyAction(_ sender: UIButton){
        terraClient?.getBody(startDate: startDate, endDate: endDate)
    }
    
    @IBAction func dailyAction(_ sender: UIButton){
        terraClient?.getDaily(startDate: startDate, endDate: endDate)
    }
    
    @IBAction func sleepAction(_ sender: UIButton){
        terraClient?.getSleep(startDate: startDate, endDate: endDate)
    }
    
    @IBAction func activityAction(_ sender: UIButton){
        terraClient?.getWorkout(startDate: startDate, endDate: endDate)
    }

    @IBAction func connectAction(){
//        let vc = (self.storyboard?.instantiateViewController(withIdentifier:"WebViewController"))
//        self.navigationController?.pushViewController(vc!, animated: true)
//        let vc = UIStoryboard.init(name: "Main", bundle:
        performSegue(withIdentifier: "PresentWebView", sender: nil)
    }
    
    @IBAction func startDateChange(_ sender: UIDatePicker){
        startDate = sender.date
    }
    
    @IBAction func endDateChange(_ sender: UIDatePicker){
        endDate = sender.date
    }
    
    @IBAction func disconnect(_ sender: UIButton){
        terraClient?.disconnectFromTerra(user_id: userId)
    }
}


class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 400, height: 400), configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        var myURL: URL!
        myURL = URL(string: getSessionId())
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
         if let urlStr = navigationAction.request.url?.absoluteString {
             print(urlStr)
             if urlStr.contains("success?resource=APPLE") {
                 webView.stopLoading()
                 userId = (TerraSwift.connectTerra(dev_id: DEVID, xAPIKey: XAPIKEY, referenceId: "testingReferenceId")?.user_id) ?? ""
                 terraClient = try! TerraSwift.Terra(dev_id: DEVID, xAPIKey: XAPIKEY)
                 print(userId)
                 self.dismiss(animated: true, completion: nil)
                 webView.removeFromSuperview()
             }
         }
        decisionHandler(.allow)
    }

    func useTerraClientExample(userId: String){
        let client = TerraSwift.TerraClient(user_id: userId, dev_id: DEVID, xAPIKey: XAPIKEY)
        print(client.getAthlete(toWebhook: false)?.message ?? "No athlete response")
        print(client.getBody(startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, toWebhook: false)?.data ?? "No body response")
    }
    
}



