//
//  ApiServiceDelegate.swift
//  APICore
//
//  Created by alexej_ne on 28/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import Moya
import RxSwift

public protocol APIServiceConfiguratorType: class {
    var baseUrl: URL { get }
    var baseHeaders: [String: String]? { get }
    var session: Session { get }
    var plugins: [Plugin] { get }
    var bodyEncoding: MethodBodyEncoding { get }
    var requestsErrorBehavior: RequestErrorBehavior? { get }
    var delegate: APIServiceConfiguratorDelegate? { get set }
    var isNeedTryRestoreAccess: Bool { get }
    func isUnauthorized(response: Response) -> Bool
}

public protocol APIServiceConfiguratorDelegate: class {
    var token: AuthToken? { get set }

    func tryRestoreAccess(response: Response?) -> Single<Void>
    
    var isTokenValid: Bool { get }
}

public extension APIServiceConfiguratorDelegate {
    var isTokenValid: Bool { true }
    
    func refreshToken() -> Single<Void> {
        tryRestoreAccess(response: nil)
    }
}
 
