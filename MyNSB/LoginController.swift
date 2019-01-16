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
        return Promise { seal in
            guard user != nil, user != "" else {
                seal.reject(MyNSBError.emptyUsername)
                return
            }

            guard password != nil, password != "" else {
                seal.reject(MyNSBError.emptyPassword)
                return
            }

            Alamofire.request("\(MyNSBRequest.domain)/user/auth", method: .post, headers: generateHeaders(user: user!, password: password!))
                .validate()
                .responseJSON { response in
                    switch response.result {
                        case .success:
                            seal.fulfill(())
                        case .failure:
                            seal.reject(MyNSBError.from(response: response))
                    }
            }
        }
    }

    @IBAction func submitLogin(_ sender: Any) {
        self.login(user: usernameField.text, password: passwordField.text).done { _ in
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        }.catch { error in
            MyNSBErrorController.error(self, error: error as! MyNSBError)
        }
    }
    
}
