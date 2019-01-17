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
import AwaitKit

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
                        guard let responseError = MyNSBError.from(response: response) else {
                            seal.reject(MyNSBError.from(error: error as NSError))
                            return
                        }
                        
                        seal.reject(responseError)
                    }
            }
        }
    }
    
    static func post(path: String, parameters: Parameters? = nil, headers: HTTPHeaders? = nil) -> Promise<DataResponse<Any>> {
        return Promise<DataResponse<Any>> { seal in
            Alamofire.request(MyNSBRequest.domain + path, method: .post, parameters: parameters, headers: headers)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        seal.fulfill(response)
                    case .failure(let error):
                        guard let responseError = MyNSBError.from(response: response) else {
                            seal.reject(MyNSBError.from(error: error as NSError))
                            return
                        }
                        
                        seal.reject(responseError)
                    }
            }
        }
    }
}
