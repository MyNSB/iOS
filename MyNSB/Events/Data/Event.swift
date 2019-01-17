//
// Created by Hanyuan Li on 20/7/18.
// Copyright (c) 2018 Qwerp-Derp. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import PromiseKit
import AlamofireImage

extension String {
    func parseEventDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        return formatter.date(from: self)!
    }
}

class Event {
    let name: String
    let start: Date
    let end: Date
    let location: String
    let organiser: String
    let shortDescription: String
    let longDescription: String
    let imageURL: String
    
    init(contents: JSON) {
        self.name = contents["EventName"].stringValue
        self.start = contents["EventStart"].stringValue.parseEventDate()
        self.end = contents["EventEnd"].stringValue.parseEventDate()
        self.location = contents["EventLocation"].stringValue
        self.organiser = contents["EventOrganiser"].stringValue
        self.shortDescription = contents["EventShortDesc"].stringValue
        self.longDescription = contents["EventLongDesc"].stringValue
        self.imageURL = contents["EventPictureURL"].stringValue
    }
    
    func image() -> Promise<Image> {
        return Promise<Image> { seal in
            let csCopy = CharacterSet(bitmapRepresentation: CharacterSet.urlPathAllowed.bitmapRepresentation)
            
            Alamofire.request(self.imageURL.addingPercentEncoding(withAllowedCharacters: csCopy)!)
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
