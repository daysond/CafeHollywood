//
//  ChatBotViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2021-06-04.
//  Copyright © 2021 Dayson Dong. All rights reserved.
//

import UIKit
import WebKit

class ChatBotViewController: UIViewController {
    
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        openChatBotSite()
        
        // Do any additional setup after loading the view.
    }
    
    private func openChatBotSite() {
        
        let url = URL(string: "https://black.korahlimited.com/oprCns/ccrChat/ccrChat.php?orgId=6950418C-B3FF-11EB-AEE2-0242AC110005")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    

 

}

extension  ChatBotViewController: WKNavigationDelegate {
    
    
    
}
