//
//  ReqresServicesConfigurator.swift
//  APICoreTests
//
//  Created by alexej_ne on 31/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import APICore
import Moya

final class ReqresServicesConfigurator: APIServiceConfiguratorType {
    var requestsErrorBehavior: RequestErrorBehavior? = nil
    
    var delegate: APIServiceConfiguratorDelegate? = nil
    
    var isNeedTryRestoreAccess: Bool = false
    
    func isUnauthorized(response: Response) -> Bool {
        return false
    }
    
    var baseHeaders: [String : String]? = nil
    var session: Session = .shared
    var bodyEncoding: MethodBodyEncoding = { _ in JSONEncoding.default}
    var baseUrl: URL = URL(string: "https://reqres.in")!
    var plugins: [Plugin] =  [NetworkLoggerPlugin(configuration: .apiCore(options: .verbose)), Plugins.tracer ]
    var authTokenProvider: AuthTokenProvider?
     
    init() {
    }
    
    init(baseUrl: String) {
        self.baseUrl = try! baseUrl.asURL()
    }
}

