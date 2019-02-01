//
//  MockKeys.swift
//  APICore
//
//  Created by alexej_ne on 30/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

public typealias MockKeyType = CaseIterable & RawRepresentable & Hashable

public enum NoMock: String, MockKeyType {
    case noMock
}
