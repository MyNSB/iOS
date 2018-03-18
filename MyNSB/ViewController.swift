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

class ViewController: UIViewController {
    let url = "https://35.189.45.152:8080/api/v1"

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func postLogin(username: String, password: String) -> Promise<Void> {
        return Promise { fulfill, reject in
            Alamofire.request("\(url)/user/Auth")
                .authenticate(username: username, password: password)
                .responseJSON { response in
                    switch response.result {
                        case .success(let value):
                            fulfill(value)
                        case .failure(let error):
                            reject(error)
                    }
                }
        }
    }

    @IBAction func submitLogin(_ sender: Any) {
        let username = usernameField.text
        let password = passwordField.text

        postLogin(username, password).then {

        }.catch {

        }
    }
}

