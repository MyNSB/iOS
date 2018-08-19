//
//  LogoutSegue.swift
//  MyNSB
//
//  Created by Hanyuan Li on 9/7/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit
import PromiseKit

class LogoutSegue: UIStoryboardSegue {
    override func perform() {
        let logoutView = self.source.view!
        let loginView = self.destination.view!

        let window = UIApplication.shared.keyWindow
        window?.insertSubview(loginView, belowSubview: logoutView)
        window?.backgroundColor = UIColor(white: 1, alpha: 1)

        loginView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)

        UIView.animate(.promise, duration: 0.75, delay: 0, animations: {
            logoutView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            loginView.transform = .identity
        }).done { _ in
            logoutView.transform = .identity
            self.source.present(self.destination, animated: false)
        }
    }
}
