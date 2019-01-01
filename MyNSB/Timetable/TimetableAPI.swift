//
//  TimetableAPI.swift
//  MyNSB
//
//  Created by Hanyuan Li on 31/12/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import Foundation

import Alamofire
import PromiseKit
import SwiftyJSON

class TimetableAPI {
    static func week() -> Promise<String> {
        return firstly {
            // Get request to week/Get
            Alamofire.request("\(MyNSBRequest.domain)/week/Get")
                .validate()     // Check that request has a valid code
                .responseJSON() // Coerces the response into a JSON format
            }.map { json, response in
                // Response is either "A" or "B"
                let body = JSON(json)["Message"]["Body"]
                return body.stringValue
        }
    }
    
    /// Fetches bell times from the API and converts it to a list of lists. There
    /// are 10 `[Timespan]`s in `bellTimes`, each one representing a day in the
    /// 10-day school fortnight. Each `[Timespan]` contains all the timespans
    /// for each period.
    ///
    /// - Returns: Bell times for the fortnight, marking the beginning and end
    ///            of each period
    static func bellTimes() -> Promise<BellTimes> {
        return firstly {
            Alamofire.request("\(MyNSBRequest.domain)/belltimes/Get")
                .validate()
                .responseJSON()
            }.map { json, _ in
                let body = JSON(json)["Message"]["Body"][0]
                return BellTimes(json: body)
        }
    }
    
    static func timetable(bellTimes: BellTimes) -> Promise<Timetable> {
        return firstly {
            Alamofire.request("\(MyNSBRequest.domain)/timetable/Get")
                .validate()
                .responseJSON()
            }.map { json, _ in
                let body = JSON(json)["Message"]["Body"][0]
                return Timetable(json: body, bellTimes: bellTimes)
        }
    }
}
