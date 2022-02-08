//
//  WebView.swift
//  PennDining
//
//  Created by Karthik Padmanabhan on 2/7/22.
//

import Foundation
import SwiftUI
import WebKit


// This WebView object allows for simple display of the Web View when the user clicks on a venue
struct WebView: UIViewRepresentable {
    
    var menuURL: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        webView.load(URLRequest(url: menuURL))
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
}


