//
//  MyNSBError.swift
//  MyNSB
//
//  Created by Hanyuan Li on 16/11/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import Foundation

enum MyNSBError: Error {
    case emptyUsername
    case emptyPassword
    case connection
    case generic(NSError)
}

extension MyNSBError: CustomStringConvertible {
    var description: String {
        switch self {
            case .emptyUsername:
                return "Username cannot be empty"
            case .emptyPassword:
                return "Password cannot be empty"
            case .connection:
                return "Connection error"
            case .generic(let error):
                return "Error code \(error.code): \(error.localizedDescription)"
        }
    }
}
