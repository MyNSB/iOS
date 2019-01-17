//
//  User.swift
//  MyNSB
//
//  Created by Hanyuan Li on 16/12/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import Foundation

import Alamofire
import PromiseKit
import AwaitKit
import SwiftyJSON

class User {
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
