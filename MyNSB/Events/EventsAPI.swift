//
//  EventsAPI.swift
//  MyNSB
//
//  Created by Hanyuan Li on 9/1/19.
//  Copyright © 2019 Qwerp-Derp. All rights reserved.
//

import Foundation

import Alamofire
import PromiseKit
import SwiftyJSON

class EventsAPI {
    static func events() -> Promise<[Event]> {
        return firstly {
            Alamofire.request("\(MyNSBRequest.domain)/events/Get")
                .validate()
                .responseJSON()
            }.map { json, response in
                let body = JSON(json)["Message"]["Body"][0].arrayValue
                
                return body.map { eventJson in
                    return Event(contents: eventJson)
                }
        }
    }
}
