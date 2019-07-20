//
//  JSONDecoder+.swift
//  APICore
//
//  Created by Alexej Nenastev on 20.07.2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import Foundation

public extension JSONDecoder {
    static let `default` = JSONDecoder()
}


public extension JSONDecoder.KeyDecodingStrategy {
    static var convertFromPascalCase: JSONDecoder.KeyDecodingStrategy {
        return .custom { keys in
            let lastKey = keys.last! // If only there was a non-empty array type...
            if lastKey.intValue != nil {
                return lastKey // It's an array key, we don't need to change anything
            }
            // lastKey.stringValue will be, e.g. "FullName"
            let firstLetter = lastKey.stringValue.prefix(1).uppercased()
            let modifiedKey = firstLetter + lastKey.stringValue.dropFirst()
            // Modified string value will be "fullName"
            return MyCodingKey(stringValue: modifiedKey)
        }
    }
}

private struct MyCodingKey: CodingKey {
    
    var stringValue: String
    
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int? {
        return nil
    }
    
    init?(intValue: Int) {
        return nil
    }
    
}
