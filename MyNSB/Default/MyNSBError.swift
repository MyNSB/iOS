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
    case API(code: Int, message: String)
}

extension MyNSBError {
    static func from(response: DataResponse<Any>) -> MyNSBError {
        let code = response.response!.statusCode
        let message = JSON(response.data!)["Message"]["Body"].stringValue
        
        return MyNSBError.API(code: code, message: message)
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
            case .API(let code, let message):
                return "Error code \(code): \(message)"
        }
    }
}
