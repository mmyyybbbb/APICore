//
//  DefaultAPISeviceConfigurator.swift
//  APICore
//
//  Created by alexej_ne on 29/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import Moya
import RxSwift

open class DefaultAPIServiceConfigurator: APIServiceConfiguratorType {
    public var delegate: APIServiceConfiguratorDelegate? = nil
    public var session: APICoreSession = .shared
    public var bodyEncoding: MethodBodyEncoding
    public var baseUrl: URL
    public var plugins: [Plugin] = []
    public var baseHeaders: [String: String]?
    public var requestsErrorBehavior: RequestErrorBehavior?
    
    public init(baseUrl: URL) {
        self.baseUrl = baseUrl
        let defaultBodyEncoding: MethodBodyEncoding = { $0 == .get ? URLEncoding.default : JSONEncoding.default }
        bodyEncoding = defaultBodyEncoding
    }
    
    public init(baseUrl: URL,
                session: Session = Session.shared,
                bodyEncoding: @escaping MethodBodyEncoding = { $0 == .get ? URLEncoding.default : JSONEncoding.default },
                plugins: [Plugin] = [],
                headers:  [String: String]?  = nil,
                requestsErrorBehavior: RequestErrorBehavior? = nil) {
        
        self.baseUrl = baseUrl
        self.session = session
        self.bodyEncoding = bodyEncoding
        self.plugins = plugins
        self.baseHeaders = headers
        self.requestsErrorBehavior = requestsErrorBehavior
    }
    
    open var isNeedTryRestoreAccess: Bool { true }
    open func isUnauthorized(response: Response) -> Bool { false }
}


