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
import AwaitKit

class EventsAPI {
    static func events() -> Promise<[Event]> {
        return async {
            let json = try await(MyNSBRequest.get(path: "/events/get"))
            let body = json[0].arrayValue
            
            return body.map { eventJSON in
                return Event(contents: eventJSON)
            }
        }
    }
}
