//
// Created by Hanyuan Li on 1/9/18.
// Copyright (c) 2018 Qwerp-Derp. All rights reserved.
//

import Foundation
import UIKit

class MyNSBErrorController {
    static func error(_ controller: UIViewController, error: MyNSBError) {
        let alertController = UIAlertController(title: "Error", message: error.description, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            if !(controller is LoginController) {
                controller.navigationController?.popViewController(animated: true)
            }
        }

        alertController.addAction(confirmAction)
        controller.present(alertController, animated: true, completion: nil)
    }
}
