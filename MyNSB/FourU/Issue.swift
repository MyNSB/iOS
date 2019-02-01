//
//  Issue.swift
//  MyNSB
//
//  Created by Jayath Gunawardena on 17/12/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import Foundation
import UIKit

import AlamofireImage
import PromiseKit
import SwiftyJSON

struct Issue {
    let name: String
    let description: String
    let imageURL: String
    let link: String
    
    init(json: JSON) {
        self.name = json["Name"].stringValue
        self.description = json["Desc"].stringValue
        self.imageURL = json["ImageUrl"].stringValue
        self.link = json["Link"].stringValue
    }
    
    /// A function that loads the image associated with the issue.
    ///
    /// - Returns: a promise containing the image for the specific 4U issue
    func image() -> Promise<Image> {
        return Promise<Image> { seal in
            Alamofire.request(self.imageURL)
                .validate()
                .responseImage { response in
                    switch response.result {
                    case .success(let value):
                        seal.fulfill(value)
                    case .failure(let error):
                        seal.reject(error)
                    }
            }
        }
    }
}
