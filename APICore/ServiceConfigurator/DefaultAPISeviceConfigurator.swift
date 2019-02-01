//
//  DefaultAPISeviceConfigurator.swift
//  APICore
//
//  Created by alexej_ne on 29/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

open class DefaultAPIServiceConfigurator: APIServiceConfiguratorType {
    
    public var sessionManager: SessionManager
    public var bodyEncoding: MethodBodyEncoding
    public var baseUrl: URL
    
    public init(baseUrl: URL) {
        self.baseUrl = baseUrl
        sessionManager = SessionManager.instance
        bodyEncoding = { _ in JSONEncoding.default}
    }
    
    public init(baseUrl: URL, sessionManager: SessionManager, bodyEncoding: @escaping MethodBodyEncoding) {
        self.baseUrl = baseUrl
        self.sessionManager = sessionManager
        self.bodyEncoding = bodyEncoding
    }
}


