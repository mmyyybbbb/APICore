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

public protocol APIServiceMethod: TargetType & MethodMeta {
    associatedtype MockKey: MockKeyType
    var owner: MethodOwner { get }
    var methodPath: MethodPath { get }
    var params: MethodParams { get }
    var mockKey: MockKey? { get }
    var multipart: [BinaryData]? { get }
    var overrideBodyEncoding: BodyEncoding? { get }
    var overrideQueryEncoding: ParameterEncoding { get }
    var overrideBaseURL: URL? { get }
}
 
public extension APIServiceMethod {
    var path: String { return methodPath.path }
    var params: MethodParams { return  MethodParams() }
    var method: HTTPMethod { return methodPath.httpMethod }
    var sampleData: Data { return Data() }
    var headers: [String : String]? { return nil }
    var baseURL: URL { return URL(string: "")! }
    var mockKey: MockKey? { return nil }
    var multipart: [BinaryData]?  { return nil }
    var overrideBodyEncoding: BodyEncoding? { return nil }
    var overrideQueryEncoding: ParameterEncoding { return URLEncoding.queryString }
    var overrideBaseURL: URL? { return nil }
    var task: Task { return .requestPlain }
    
}

/// Мета информация о методе
public protocol MethodMeta {
    var owner: MethodOwner { get }
}
//  Указывает владельца метода
public protocol MethodOwner {
    // Область функционала по бизнесу к которой принадлежит метод
    var scopeName: String { get }
    // Владелец
    var owner: String { get }
}
