//
//  APIClient.swift
//  MyNSB
//
//  Created by Jayath Gunawardena on 17/12/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

class FourUAPI {
    private func getFourU() -> Promise<String> {
        return firstly {
            Alamofire.request("http://35.189.50.185:8080/api/v1/4U/Get")
            .validate()
            .responseJSON()
        }.map{ json, response in
            return "Hello World"
        }
    }

    private func CreateFourU () -> Promise<String> {
        return firstly {
            Alamofire.request("http://35.189.50.185:8080/api/v1/4U/Create")
            .validate()
            .responseJSON()
            }.map{ json, response in
                return "Hello World"
        }
    }

}


