//
//  DefaultAPISeviceConfigurator.swift
//  APICore
//
//  Created by alexej_ne on 29/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

open class DefaultAPIServiceConfigurator: APIServiceConfiguratorType, AuthTokenProvider {
    
    public var sessionManager: SessionManager
    public var bodyEncoding: MethodBodyEncoding
    public var baseUrl: URL
    public var plugins: [Plugin] = []
    public var baseHeaders: [String: String]? 
    public weak var authTokenProvider: AuthTokenProvider? = nil
    public private(set) var token: AuthToken?
    
    public init(baseUrl: URL) {
        self.baseUrl = baseUrl
        sessionManager = SessionManager.instance
        
        let defaultBodyEncoding: MethodBodyEncoding = { $0 == .get ? URLEncoding.default : JSONEncoding.default }
        bodyEncoding = defaultBodyEncoding
    }
    
    public init(baseUrl: URL,
                sessionManager: SessionManager = SessionManager.instance,
                bodyEncoding: @escaping MethodBodyEncoding = { $0 == .get ? URLEncoding.default : JSONEncoding.default },
                plugins: [Plugin] = [],
                headers:  [String: String]?  = nil ) {
        
        self.baseUrl = baseUrl
        self.sessionManager = sessionManager
        self.bodyEncoding = bodyEncoding
        self.plugins = plugins
        self.baseHeaders = headers
    }
    
    public func setTokenProviderToSelf(with token: AuthToken) {
        authTokenProvider = self
        self.token = token
    }
}


