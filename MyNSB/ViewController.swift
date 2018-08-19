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
    private var alertController = UIAlertController()

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    private func checkLogin() -> Promise<Bool> {
        return Promise { seal in
            Alamofire.request("http://35.189.50.185:8080/api/v1/user/GetDetails")
                .responseJSON { response in
                    if response.response!.statusCode == 400 {
                        seal.fulfill(false)
                        return
                    }

                    switch response.result {
                        case .success:
                            seal.fulfill(true)
                        case .failure(let error):
                            seal.reject(error)
                    }
                }
        }
    }
    
    override func viewDidLoad() {
        checkLogin().done { verified in
            if verified {
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            }
        }.catch { error in
            debugPrint(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func initAlertController(error: Error) {
        self.alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
        }

        self.alertController.addAction(confirmAction)
        self.present(self.alertController, animated: true, completion: nil)
    }

    private func generateHeaders(user: String, password: String) -> HTTPHeaders? {
        return [
            "Authorization": "Basic " + (user + ":" + password).data(using: .utf8)!.base64EncodedString()
        ]
    }

    private func login(user: String?, password: String?) -> Promise<Void> {
        return Promise { seal in
            guard user != nil, user != "" else {
                seal.reject(NSError(domain: "", code: 203, userInfo: [NSLocalizedDescriptionKey: "Username is empty"]))
                return
            }

            guard password != nil, password != "" else {
                seal.reject(NSError(domain: "", code: 202, userInfo: [NSLocalizedDescriptionKey: "Password is empty"]))
                return
            }

            Alamofire.request("http://35.189.50.185:8080/api/v1/user/Auth", method: .post, headers: generateHeaders(user: user!, password: password!))
                .validate()
                .responseJSON { response in
                    switch response.result {
                        case .success:
                            seal.fulfill(())
                        case .failure(let error):
                            seal.reject(error)
                    }
                }
        }
    }

    @IBAction func submitLogin(_ sender: Any) {
        login(user: usernameField.text, password: passwordField.text).done { _ in
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        }.catch { error in
            self.initAlertController(error: error)
        }
    }
}
