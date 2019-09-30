//
//  ReqresServicesConfigurator.swift
//  APICoreTests
//
//  Created by alexej_ne on 31/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import APICore

final class ReqresServicesConfigurator: APIServiceConfiguratorType {
    var baseHeaders: [String : String]? = nil
    var sessionManager: SessionManager = SessionManager.instance
    var bodyEncoding: MethodBodyEncoding = { _ in JSONEncoding.default}
    var baseUrl: URL = URL(string: "https://reqres.in")!
    var plugins: [Plugin] = [Plugins.logger()]
    var authTokenProvider: AuthTokenProvider?
    
    init() { }
    
    init(baseUrl: String) {
        self.baseUrl = try! baseUrl.asURL()
    }
}
