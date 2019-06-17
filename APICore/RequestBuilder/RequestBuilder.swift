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
        
        if let behavior = S.configurator?.requestsErrorBehavior {
            return request(forceErrorBehavior: behavior)
        }
        
        return requestWithoutErrorBehavior()
    }
    
    public func request(forceErrorBehavior behavior: RequestErrorBehavior) -> Single<Response> {
        
        func catchError(error: Error) throws -> Single<Response> {
            return try onCatchError(behavior: behavior, error: error)
        }
        
        return _request().catchError(catchError)
    }
    
    public func requestWithoutErrorBehavior() -> Single<Response> {
        return _request()
    }
    
    /// depricated
    public func requestWithMap<T:Decodable>() -> Single<T> {
        return _request()
            .map { response in return try JSONDecoder().decode(T.self, from: response.data) }
            .observeOn(MainScheduler.instance)
    }
    
    /// depricated
    public func requestWithVoid() -> Single<Void> {
        return _request()
            .map { response in return Void() }
            .observeOn(MainScheduler.instance)
    }
    
    private func _request() -> Single<Response> {
        
        let notifyAboutError: (Error) -> Void = { APICoreManager.shared.requestHttpErrorsPublisher.onNext(extractNSError(from: $0)) }
        
        return S.shared.provider.rx
            .request(method, callbackQueue: DispatchQueue.global())
            .do(onError: notifyAboutError)
    }
    
    private func onCatchError(behavior: RequestErrorBehavior, error: Error) throws  -> Single<Response> {
        let nsError = extractNSError(from: error)
        
        guard nsError.domain == NSURLErrorDomain else { throw error }
        
        switch behavior {
        case let .autoRepeatWhen(nsUrlErrorDomainCodeIn, maxRepeatCount, repeatAfter):
            guard nsUrlErrorDomainCodeIn.contains(nsError.code), maxRepeatCount > 0  else { break }
            let behavior = RequestErrorBehavior.autoRepeatWhen(nsUrlErrorDomainCodeIn: nsUrlErrorDomainCodeIn,
                                                                      maxRepeatCount: maxRepeatCount-1,
                                                                      repeatAfter: repeatAfter)
            return request(forceErrorBehavior:  behavior)
                .delaySubscription(repeatAfter, scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated)) 
            
        case let .autoRepeat(maxRepeatCount, repeatAfter):
            guard maxRepeatCount > 0  else { break }
            let behavior = RequestErrorBehavior.autoRepeat(maxRepeatCount: maxRepeatCount-1, repeatAfter: repeatAfter)
            return request(forceErrorBehavior:  behavior)
                .delaySubscription(repeatAfter, scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
        }
        
        throw error
    }
}

fileprivate func extractNSError(from error: Error) -> NSError {
    if case MoyaError.underlying(let err, _) = error  {
        return err as NSError
    }
    return error as NSError
}

public extension Single where Element == Response {
    
    func mapTo<T:Decodable>(on scheduler: ImmediateSchedulerType = MainScheduler.instance) -> Single<T> {
        return self
            .asObservable()
            .map { response in return try JSONDecoder().decode(T.self, from: response.data) }
            .asSingle()
            .observeOn(scheduler)
    }
    
    func mapToVoid(on scheduler: ImmediateSchedulerType = MainScheduler.instance) -> Single<Void> {
        return self
            .asObservable()
            .map { response in return Void() }
            .asSingle()
            .observeOn(scheduler)
    }
}


