//
//  LoadingControllerViewController.swift
//  MyNSB
//
//  Created by Hanyuan Li on 17/12/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit

import AwaitKit

class LoadingController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.startAnimating()

        // Do any additional setup after loading the view.
        
        async {
            let flag = try! await(User.isLoggedIn())
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.performSegue(withIdentifier: flag ? "mainPage" : "needsLogin", sender: nil)
            }
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
