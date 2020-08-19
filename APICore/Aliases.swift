//
//  Aliases.swift
//  APICore
//
//  Created by alexej_ne on 31/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import Moya
import Alamofire

public typealias APICoreSession = Alamofire.Session
public typealias BodyEncoding = ParameterEncoding
public typealias MethodBodyEncoding = (APIHTTPMethod) -> BodyEncoding
public typealias APIHTTPMethod = HTTPMethod
public typealias MethodPath = (httpMethod: APIHTTPMethod, path: String)
public typealias URLEncoding = Alamofire.URLEncoding
public typealias JSONEncoding = Alamofire.JSONEncoding
public typealias Plugin = PluginType
public typealias AuthToken = String 

public extension Session {
    static var shared: Session = .default
}
