//
//  RequestErrorBehavior.swift
//  APICore
//
//  Created by alexej_ne on 17.06.2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import RxSwift

public enum RequestErrorBehavior {
    case autoRepeatWhen(nsUrlErrorDomainCodeIn: [Int], maxRepeatCount: Int, repeatAfter: DispatchTimeInterval)
    case autoRepeat(maxRepeatCount: Int, repeatAfter: DispatchTimeInterval) 
}
