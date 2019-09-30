//
//  Dictionary+.swift
//  APICore
//
//  Created by alexej_ne on 07/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

public extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    mutating func addIfNotEmty(key: Key, value: String?) {
        guard let value = value, value.isEmpty == false else {
            return
        }
        self[key] = value as? Value
    }
}
