//
//  LoadingControllerViewController.swift
//  MyNSB
//
//  Created by Hanyuan Li on 17/12/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit

class LoadingController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.startAnimating()

        // Do any additional setup after loading the view.
        
        User.isLoggedIn().done { flag in
            self.activityIndicator.stopAnimating()
            
            if flag {
                self.performSegue(withIdentifier: "mainPage", sender: nil)
            } else {
                self.performSegue(withIdentifier: "needsLogin", sender: nil)
            }
        }.catch { error in
            
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
