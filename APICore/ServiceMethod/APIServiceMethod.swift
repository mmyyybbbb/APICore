//
//  APIRequest.swift
//  APICore
//
//  Created by alexej_ne on 28/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import Moya
import Alamofire
import UIKit

public protocol APIServiceMethod: TargetType {
    associatedtype MockKey: MockKeyType
    
    var methodPath: MethodPath { get }
    var params: MethodParams { get }
    var mockKey: MockKey? { get }
    var multipart: BinaryData? { get }
    var overrideBodyEncoding: ParameterEncoding? { get }
}

public extension APIServiceMethod {
    var path: String { return methodPath.path }
    var params: MethodParams { return  MethodParams() }
    var method: HTTPMethod { return methodPath.httpMethod }
    var sampleData: Data { return Data() }
    var headers: [String : String]? { return nil }
    var baseURL: URL { return URL(string: "")! }
    var mockKey: MockKey? { return nil }
    var multipart: BinaryData?  { return nil }
    var overrideBodyEncoding: ParameterEncoding? { return nil }
    var task: Task { return .requestPlain } 
}




