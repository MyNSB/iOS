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
import SwiftyJSON

class User {
    static func isLoggedIn() -> Promise<Bool> {
        return Promise { seal in
            Alamofire.request("\(MyNSBRequest.domain)/user/GetDetails")
                .responseJSON { response in
                    if response.response?.statusCode != 200 {
                        seal.fulfill(false)
                        return
                    }
                    
                    switch response.result {
                        case .success:
                            seal.fulfill(true)
                        case .failure(let error):
                            seal.reject(MyNSBError.generic(error as NSError))
                    }
            }
        }
    }
}
