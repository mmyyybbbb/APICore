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
    
    public static var instanceLazyInit: APICoreObjectContainer {
        if let instance = instance {
            return instance
        }
        
        let newInst = APICoreObjectContainer()
        instance = newInst
        return newInst
    }
    
    private var configurators: [APIServiceConfiguratorType] = []
    private var serviceConfigurators: [String : APIServiceConfiguratorType] = [:]
    private var services: [String: Any] = [:]
 
    private init() { }
    
    public static func releaseInstance() {
        instance = nil
    }
    
    public func register(_ configurator: APIServiceConfiguratorType) {
       configurators.append(configurator)
    }
    
    public func register<S:APIServiceType>(configurator: APIServiceConfiguratorType, for service: S.Type) {
        let key = "\(S.Method.self)"
        serviceConfigurators[key] = configurator
    }
    
    func resolveOrRegisterService<S:APIServiceType>() -> S {
        let key = "\(S.self)"
        
        if let service = services[key] {
            guard let service = service as? S else {
                fatal("Сервис имеет некорректный тип")
            }
            
            return service
        }
        
        let service = S.init()
        services[key] = service
        return service
    }
    
    func resolveServiceConfigurator<C:APIServiceConfiguratorType>() -> C? {
        guard let configurator = configurators.first(where: {$0 is C}) as? C else {
            error("\(C.self) такой конфигуратор не зарегестрирован в APICoreObjectContainer")
            return nil
        }
        
        return configurator
    }
    
    func resolveServiceConfigurator<C:APIServiceConfiguratorType, S:APIServiceType>(for service: S.Type) -> C? {
        let key = "\(S.Method.self)"
        
        guard let configurator = serviceConfigurators[key] as? C else {
            return resolveServiceConfigurator()
        }
        
        return configurator
    }
}
