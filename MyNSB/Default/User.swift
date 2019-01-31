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
    /// Generate basic authentication headers for a user
    static func generateHeaders(user: String, password: String) -> HTTPHeaders {
        return [
            "Authorization": "Basic " + (user + ":" + password).data(using: .utf8)!.base64EncodedString()
        ]
    }
    
    /// Checks if the current user is logged in or not. Uses /user/getDetails
    /// internally. May throw if an error occurs with the app.
    ///
    /// - Returns: Whether the user is logged in or not
    static func isLoggedIn() -> Promise<Bool> {
        return async {
            do {
                try await(
                    MyNSBRequest.post(
                        path: "/user/auth",
                        headers: User.generateHeaders(user: "a", password: "a")
                    )
                )
                return false
            } catch let error as MyNSBError {
                if case let MyNSBError.api(code, message) = error {
                    if code == 400 && message == "Already Logged In" {
                        return true
                    }
                }
                
                throw error
            }
        }
    }
}
