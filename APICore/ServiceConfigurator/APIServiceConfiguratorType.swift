//
//  ApiServiceDelegate.swift
//  APICore
//
//  Created by alexej_ne on 28/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import Moya

public protocol APIServiceConfiguratorType: class {
    var baseUrl: URL { get }
    var baseHeaders: [String: String]? { get }
    var sessionManager: SessionManager { get }
    var plugins: [Plugin] { get }
    var bodyEncoding: MethodBodyEncoding { get }
}

extension APIServiceConfiguratorType {
    public var baseHeaders: [String: String]? { return nil } 
    public var plugins: [Plugin] { return [] } 
}


