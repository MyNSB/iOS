//
//  WebController.swift
//  MyNSB
//
//  Created by Hanyuan Li on 25/1/19.
//  Copyright © 2019 Qwerp-Derp. All rights reserved.
//

import UIKit
import WebKit

class WebController: UIViewController, WKNavigationDelegate {
    var website: URL?
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.navigationDelegate = self

        // Do any additional setup after loading the view.
        
        if let website = self.website {
            let request = URLRequest(url: website)
            self.webView.load(request)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
