//
// Created by Hanyuan Li on 2/9/18.
// Copyright (c) 2018 Qwerp-Derp. All rights reserved.
//

import Foundation
import Alamofire

struct Connection {
    static let instance = NetworkReachabilityManager()!

    static var isConnected: Bool {
        return self.instance.isReachable
    }
}
