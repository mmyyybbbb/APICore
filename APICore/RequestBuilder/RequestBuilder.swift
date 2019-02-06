//
//  DataRequest.swift
//  APICore
//
//  Created by alexej_ne on 28/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import Moya
import RxSwift

import Foundation

open class RequestBuilder<S: APIServiceType>  {
  
    private let method: S.Method
    
    public init(_ type: S.Type, _ method: S.Method) {
        self.method = method
    }
  
    public func request() -> Single<Response> {
        return S.shared.provider.rx.request(method)
    }
    
    public func map<T:Decodable>() -> Single<T> {
        return request().map { response in
            return try JSONDecoder().decode(T.self, from: response.data)
        }
    }
    
}



