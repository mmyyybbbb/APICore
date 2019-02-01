//
//  APIServiceType.swift
//  APICore
//
//  Created by alexej_ne on 11/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import Moya


public protocol APIServiceType: class {
    associatedtype Method: APIServiceMethod
    associatedtype Configurator: APIServiceConfiguratorType
    
    var useMocksIfSetted: Bool { get }
    var provider: MoyaProvider<Method> { get }
    var urlServicePathComponent: String { get }
    var serviceHeaders: [String: String]? { get }
    
    init()
}

extension APIServiceType {
    // прежде чем вызывать данный сервис убедитесь что APICoreObjectContainer существует
    static var shared: Self {  return APICoreObjectContainer.instanceLazyInit.resolveOrRegisterService()  }
    static var configurator: Configurator? { return APICoreObjectContainer.instanceLazyInit.resolveServiceConfigurator(for: Self.self) }
}

