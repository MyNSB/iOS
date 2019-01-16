//
//  MyNSBRequest.swift
//  MyNSB
//
//  Created by Hanyuan Li on 31/12/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON
import PromiseKit

class MyNSBRequest {
    static let domain = "https://mynsb.nsbvisions.com/api/v1"
    
    static func get(path: String) -> Promise<JSON> {
        return Promise<JSON> { seal in
            Alamofire.request(MyNSBRequest.domain + path)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        seal.fulfill(JSON(value)["Message"]["Body"])
                    case .failure(let error):
                        guard response.data != nil && response.response != nil else {
                            seal.reject(error)
                            return
                        }
                        
                        seal.reject(MyNSBError.from(response: response))
                    }
            }
        }
    }
}
