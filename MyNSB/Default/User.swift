//
//  User.swift
//  MyNSB
//
//  Created by Hanyuan Li on 16/12/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import Foundation

import Alamofire
import AwaitKit
import PromiseKit

class User {
    /// Checks if the current user is logged in or not. Uses /user/getDetails
    /// internally. May throw if an error occurs with the app.
    ///
    /// - Returns: Whether the user is logged in or not
    static func isLoggedIn() -> Promise<Bool> {
        return async {
            do {
                try await(MyNSBRequest.get(path: "/user/getDetails"))
                return true
            } catch let error as MyNSBError {
                switch error {
                case .api:
                    return false
                default:
                    throw error
                }
            }
        }
    }
}
