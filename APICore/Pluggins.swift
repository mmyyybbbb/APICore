//
//  Pluggins.swift
//  APICore
//
//  Created by alexej_ne on 31/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import Moya

public final class Plugins {
    
    public static func logger() -> PluginType {
        return NetworkLoggerPlugin(verbose: true, cURL: true,
                            responseDataFormatter: JSONResponseDataFormatter)
    }
    
    private static func JSONResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data
        }
    }
}
