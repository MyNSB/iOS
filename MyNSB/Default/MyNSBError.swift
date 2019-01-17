//
//  MyNSBError.swift
//  MyNSB
//
//  Created by Hanyuan Li on 16/11/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

enum MyNSBError: Error {
    case emptyUsername
    case emptyPassword
    case connection
    case api(code: Int, message: String)
    case generic(message: String)
}

extension MyNSBError {
    static func from(response: DataResponse<Any>) -> MyNSBError? {
        guard response.response != nil, response.data != nil else {
            return nil
        }
        
        let code = response.response!.statusCode
        let message = JSON(response.data!)["Message"]["Body"].stringValue
        
        return MyNSBError.api(code: code, message: message)
    }
    
    static func from(error: NSError) -> MyNSBError {
        return MyNSBError.generic(message: error.localizedDescription)
    }
}

extension MyNSBError: CustomStringConvertible {
    var description: String {
        switch self {
        case .emptyUsername:
            return "Username cannot be empty"
        case .emptyPassword:
            return "Password cannot be empty"
        case .connection:
            return "Cannot connect to the Internet"
        case .api(let code, let message):
            return "Error code \(code): \(message)"
        case .generic(let message):
            return message
        }
    }
}
