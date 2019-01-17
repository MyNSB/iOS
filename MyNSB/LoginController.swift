//
//  ViewController.swift
//  MyNSB
//
//  Created by Hanyuan Li on 16/1/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PromiseKit
import AwaitKit

class LoginController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    @objc private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.usernameField.resignFirstResponder()
        self.passwordField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(gesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func generateHeaders(user: String, password: String) -> HTTPHeaders? {
        return [
            "Authorization": "Basic " + (user + ":" + password).data(using: .utf8)!.base64EncodedString()
        ]
    }

    private func login(user: String?, password: String?) -> Promise<Void> {
        return async {
            guard user != nil, user != "" else {
                throw MyNSBError.emptyUsername
            }
            
            guard password != nil, password != "" else {
                throw MyNSBError.emptyPassword
            }
            
            try await(
                MyNSBRequest.post(
                    path: "/user/auth",
                    headers: self.generateHeaders(user: user!, password: password!)
                )
            )
        }
    }

    @IBAction func submitLogin(_ sender: Any) {
        let user = self.usernameField.text
        let password = self.passwordField.text
        
        async {
            do {
                try await(self.login(user: user, password: password))
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                }
            }
        }
    }
    
}
