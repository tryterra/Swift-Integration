//
//  Widget.swift
//  Terra
//
//  Created by Elliott Yu on 11/10/2021.
//

import Foundation
import WebKit
import UIKit
import Combine
import SwiftUI
import TerraSwift

extension URL {
    subscript(queryParam:String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParam })?.value
    }
}

extension WKWebView{
    private var httpCookieStore: WKHTTPCookieStore { return WKWebsiteDataStore.default().httpCookieStore}
    
    func getCookies(completion: @escaping ([String: Any]) -> ()) {
        var allCookies = [String: AnyObject]()
        httpCookieStore.getAllCookies{cookies in
            for cookie in cookies {
                allCookies[cookie.name] = cookie.properties as AnyObject?
            }
        }
        completion(allCookies)
    }
}

public struct TerraWidget: UIViewRepresentable {

    @ObservedObject public var widget: WebViewTerra
    var wkPreferences: WKPreferences
    var configuration: WKWebViewConfiguration
    var webView: WKWebView
    
    public init(webViewTerra: WebViewTerra){
        self.widget = webViewTerra
        self.wkPreferences = WKPreferences()
        self.wkPreferences.javaScriptCanOpenWindowsAutomatically = true
        self.configuration = WKWebViewConfiguration()
        self.configuration.preferences = wkPreferences
        self.webView = WKWebView(frame: .zero, configuration: configuration)
    }

    
    public func makeUIView(context: UIViewRepresentableContext<TerraWidget>) -> WKWebView {
        self.webView.navigationDelegate = context.coordinator
        self.webView.uiDelegate = context.coordinator
        if let url = URL(string: widget.link) {
            self.webView.load(URLRequest(url: url))
        }
        return self.webView
    }

    public func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<TerraWidget>) {
        return
    }
    public func close(){
        self.webView.removeFromSuperview()
    }

    public class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate{
        public var widget: WebViewTerra

        public init(_ widget: WebViewTerra) {
            self.widget = widget
        }
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
            print(webView.url!.absoluteString)
            if webView.url!.absoluteString.contains("apple_auth=true"){
                webView.removeFromSuperview()
                widget.authenticated = true
                webView.getCookies{cookies in
                    print(cookies)
                }
                widget.user_id = connectTerra(dev_id: DEVID, xAPIKey: XAPIKEY)
                widget.TerraClient = Terra(user_id: widget.user_id, dev_id: DEVID, xAPIKey: XAPIKEY, enableHr: true)
            }
            else if webView.url!.absoluteString.contains("https://widget.tryterra.co/?auth=true&user-id="){
                webView.removeFromSuperview()
                widget.user_id = webView.url!["user-id"]!
                widget.authenticated = true
            }
        }
        
        public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            print(navigationAction.request)
            UIApplication.shared.open(navigationAction.request.url!)
            return nil
        }
    }
    

    public func makeCoordinator() -> TerraWidget.Coordinator {
        Coordinator(widget)
    }
}

public class WebViewTerra: ObservableObject {
    @Published var link: String
    @Published var authenticated: Bool = false
    @Published var TerraClient: Terra?
    @Published var user_id: String

    public init (url: String) {
        self.link = url
        self.user_id = ""
        self.TerraClient = nil
    }
}

