//
//  Parsers.swift
//  BrokerAPIServices
//
//  Created by Andrey Raevnev on 13/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import Foundation

public typealias DataParser<R> = (Data) throws -> R

public final class Parsers {
    
    public static func instance<T, R>(transform: @escaping (T) throws -> R) -> DataParser<R> {
        return {
            if let data = try JSONSerialization.jsonObject(with: $0) as? T {
                return try transform(data)
            } else {
                throw "💥 DECODE ERROR: cant cast data to \(T.self)"
            }
        }
    }
    
    public static func instance<R:Decodable>(decoderUserInfo: [CodingUserInfoKey: Any] = [:]) -> DataParser<R> {
        return {
            let decoder = JSONDecoder()
            decoder.userInfo = decoderUserInfo
            return try decoder.decode(R.self, from: $0)
        }
    }
}

extension String: Error {}
