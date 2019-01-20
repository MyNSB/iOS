//
//  MyNSBError.swift
//  MyNSB
//
//  Created by Hanyuan Li on 16/11/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

/// A custom error class for all error types within the MyNSB application.
///
/// - api: an API error
/// - connection: the app can't connect to the Internet for some reason
/// - emptyUsername: the user has an empty username field in the login screen
/// - emptyPassword: the user has an empty password field in the login screen
/// - generic: an error within the application, usually isn't raised
enum MyNSBError: Error {
    case api(code: Int, message: String)
    case connection
    case emptyUsername
    case emptyPassword
    case generic(message: String)
}

extension MyNSBError {
    /// Converts a response from the API into a MyNSBError if the response does
    /// not return any meaningful data.
    ///
    /// - Parameter response: a response object from API calls
    /// - Returns: `MyNSBError` if the response contains all the necessary
    /// information to generate an error report, `nil` otherwise
    static func from(response: DataResponse<Any>) -> MyNSBError? {
        guard response.response != nil, response.data != nil else {
            return nil
        }
        
        let code = response.response!.statusCode
        let message = JSON(response.data!)["Message"]["Body"].stringValue
        
        return MyNSBError.api(code: code, message: message)
    }
    
    /// Converts a standard error generated within the application into a `MyNSBError`
    /// that `MyNSBErrorController` can handle.
    ///
    /// - Parameter error: an error generated from the app
    /// - Returns: a `MyNSBError` that contains all the information from `error`
    static func from(error: NSError) -> MyNSBError {
        return MyNSBError.generic(message: error.localizedDescription)
    }
}

extension MyNSBError: CustomStringConvertible {
    var description: String {
        switch self {
        case .api(let code, let message):
            return "Error code \(code): \(message)"
        case .connection:
            return "Cannot connect to the Internet"
        case .emptyUsername:
            return "Username cannot be empty"
        case .emptyPassword:
            return "Password cannot be empty"
        case .generic(let message):
            return message
        }
    }
}
