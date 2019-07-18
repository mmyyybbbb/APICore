//
//  ServiceRedirect.swift
//  BrokerAPIServices
//
//  Created by Alexej Nenastev on 18.07.2019.
//  Copyright © 2019 BCS. All rights reserved.
//

public typealias MethodLocation = String

public struct MethodRedirect {
    
    public let location: MethodLocation
    public let retryInterval: Int
    
    public init(_ response: HTTPURLResponse?) throws {
        guard let location = response?.allHeaderFields["Location"] as? String else { throw "Отсутсвует location" }
        self.location = location
        self.retryInterval = Int(response?.allHeaderFields["retry-after"] as? String ?? "3") ?? 3
    }
}
