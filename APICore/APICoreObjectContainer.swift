//
//  APICoreObjectContainer.swift
//  APICore
//
//  Created by alexej_ne on 28/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import Alamofire

public final class APICoreObjectContainer {
    private static var instance: APICoreObjectContainer?
    
    static var instanceLazyInit: APICoreObjectContainer {
        if let instance = instance {
            return instance
        }
        
        let newInst = APICoreObjectContainer()
        instance = newInst
        return newInst
    }
    
    private var configurators: [APIServiceConfiguratorType] = []
    private var services: [String: Any] = [:]
 
    private init() { }
    
    public static func releaseInstance() {
        instance = nil
    }
    
    public func register(_ configurator: APIServiceConfiguratorType) {
       configurators.append(configurator)
    }
    
    func resolveOrRegisterService<T:APIServiceType>() -> T {
        let key = "\(T.self)"
        
        if let service = services[key] {
            guard let service = service as? T else {
                fatal("Сервис имеет некорректный тип")
            }
            
            return service
        }
        
        let service = T.init()
        services[key] = service
        return service
    }
    
    func resolveServiceConfigurator<T:APIServiceConfiguratorType>() -> T? {
        guard let configurator = configurators.first(where: {$0 is T}) as? T else {
            error("\(T.self) такой конфигуратор не зарегестрирован в APICoreObjectContainer")
            return nil
        }
        
        return configurator
    }
}
