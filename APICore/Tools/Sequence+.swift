//
//  Sequence+.swift
//  BrokerAPIServices
//
//  Created by alexej_ne on 18.06.2019.
//  Copyright © 2019 BCS. All rights reserved.
//

public extension Sequence where Iterator.Element == Int {
    func joinWithComma() -> String {
        return self.map(String.init).joined(separator: ",")
    }
}
