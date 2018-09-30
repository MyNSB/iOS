//
// Created by Hanyuan Li on 1/9/18.
// Copyright (c) 2018 Qwerp-Derp. All rights reserved.
//

import Foundation
import UIKit

class MyNSBErrorController {
    static func error(_ controller: UIViewController, error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
        }

        alertController.addAction(confirmAction)
        controller.present(alertController, animated: true, completion: nil)
    }
}