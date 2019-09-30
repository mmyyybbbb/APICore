//
//  KeyedDecodingContainer+.swift
//  BrokerAPIServices
//
//  Created by Andrey Raevnev on 13/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import Foundation 

fileprivate func dateFromJSONString(_ json: String?) -> Date? {
    guard let json = json else { return nil }
    return isoDateFormatter.date(from: json)
}

fileprivate let isoDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    
    formatter.locale     = Locale(identifier: "ru_RU")
    formatter.timeZone   = TimeZone.autoupdatingCurrent
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    
    return formatter
}()

public extension KeyedDecodingContainer {
    subscript<T: Decodable>(key: KeyedDecodingContainer.Key) -> T? {
        return try? decode(T.self, forKey: key)
    }
    
    func getFor<T: Decodable>(_ key: KeyedDecodingContainer.Key) throws -> T {
        return try decode(T.self, forKey: key)
    }
    
    func getFor<T: Decodable>(_ key: KeyedDecodingContainer.Key, default: T)  -> T {
        let val:T? =  try? decode(T.self, forKey: key)
        
        if let val = val {  return val }
        return `default`
    }
    
    func getFor(_ key: KeyedDecodingContainer.Key) throws -> NSDecimalNumber {
        return try decode(NSDecimalNumber.self, forKey: key)
    }
    
    func getFor(_ key: KeyedDecodingContainer.Key) throws -> [String: Any] {
        return try decode([String: Any].self, forKey: key)
    }
    
    func getFor(_ key: KeyedDecodingContainer.Key, default: NSDecimalNumber) -> NSDecimalNumber {
        
        if let res = try? decode(NSDecimalNumber.self, forKey: key) {
            return res
        } else {
            return `default`
        }
    }
    
    func getOptional(for key: KeyedDecodingContainer.Key) -> NSDecimalNumber? {
        
        if let res = try? decode(NSDecimalNumber.self, forKey: key) {
            return res
        } else {
            return nil
        }
    }
    
    func decode(_ type: NSDecimalNumber.Type, forKey key: KeyedDecodingContainer.Key) throws -> NSDecimalNumber {
        
        if let asDecimal:Decimal = try? self.getFor(key) {
            return NSDecimalNumber(decimal: asDecimal)
        }
        
        let asString:String = try self.getFor(key)
        return NSDecimalNumber(string: asString)
    }
    
    func decodeDateOrToday(_ key: KeyedDecodingContainer.Key) -> Date {
        if let time = dateFromJSONString(getFor(key, default: "")) {
            return time
        }
        return Date().startOfDay
    }
    
    func decodeDate(_ key: KeyedDecodingContainer.Key) -> [Date] {
        
        guard let datesString:[String] = try? self.getFor(key) else { return []}
        return datesString.compactMap { dateFromJSONString($0) }
    }
    
    func decodeDate(_ key: KeyedDecodingContainer.Key) throws -> Date {
        
        let asString:String = try self.getFor(key)
        guard let time = dateFromJSONString(asString)  else { throw "Can't parse date form JSON" }
        return time
    }
    
    func decodeDateOptional(_ key: KeyedDecodingContainer.Key) -> Date? {
        
        guard let asString:String = try? self.getFor(key),
            let time = dateFromJSONString(asString)
            else { return nil }
        return time
    }
    
    func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }
    
    func decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any>? {
        guard contains(key) else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }
    
    func decodeIfPresent(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any>? {
        guard contains(key) else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()
        
        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }
}

