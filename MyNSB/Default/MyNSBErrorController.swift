//
// Created by Hanyuan Li on 1/9/18.
// Copyright (c) 2018 Qwerp-Derp. All rights reserved.
//

import Foundation
import UIKit

class MyNSBErrorController {
    /// Creates an error pop-up over a view controller to inform the user that
    /// something has gone wrong.
    ///
    /// - Parameters:
    ///   - controller: The controller that has the pop-up displayed over it, usually `self`
    ///   - error: An error from the API or the app itself (`MyNSBError`)
    static func error(_ controller: UIViewController, error: MyNSBError) {
        let alertController = UIAlertController(title: "Error", message: error.description, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            if controller is LoadingController {
                exit(0)
            } else if !(controller is LoginController) {
                controller.navigationController?.popViewController(animated: true)
            }
        }

        DispatchQueue.main.async {
            alertController.addAction(confirmAction)
            controller.present(alertController, animated: true, completion: nil)
        }
    }
}
