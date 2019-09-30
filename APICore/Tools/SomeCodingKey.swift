//
//  SomeCodingKey.swift
//  BrokerAPIServices
//
//  Created by Andrey Raevnev on 13/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

public struct SomeCodingKey : CodingKey {
    
    static let keyForLooking = CodingUserInfoKey(rawValue: "keyForLooking")!
    
    public let stringValue: String
    public let intValue: Int?
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    public init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
