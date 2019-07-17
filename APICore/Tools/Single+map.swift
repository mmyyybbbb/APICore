//
//  Single+map.swift
//  BrokerAPIServices
//
//  Created by Andrey Raevnev on 07/06/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import RxSwift

public extension PrimitiveSequence { 
    func map<R>(_ transform: @escaping (PrimitiveSequence.E) throws -> R) -> Single<R> {
        return self.asObservable().map(transform).asSingle()
    }
}
