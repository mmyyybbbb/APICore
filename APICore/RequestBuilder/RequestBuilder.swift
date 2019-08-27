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
    
    private func _request() -> Single<Response> {
        
        let notifyAboutError: (Error) -> Void = { APICoreManager.shared.requestHttpErrorsPublisher.onNext(extractNSError(from: $0)) }
        
        func req() -> Single<Response> {
            return S.shared.provider.rx
                .request(method, callbackQueue: DispatchQueue.global())
                .do(onError: notifyAboutError)
        }
        
        if let delegate = S.configurator?.delegate {
            
            func status303(response: Response) -> Single<Response> {
                return delegate.tryRestoreAccessWhen403(response: response).flatMap { req() }
            }
            return req().flatMap(status303)
        } else {
            return req()
        }
        
    }
    
    private func  onCatchError(behavior: RequestErrorBehavior, error: Error) throws  -> Single<Response> {
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

/// Ошибка парсинга данных
public struct DecodeError: Error {
    public let error: Error
    public let response: Response
    public let targetTypeDescription: Any
}

public extension Single where Element == Response {
    
    func mapTo<T:Decodable>(_ type: T.Type, on scheduler: ImmediateSchedulerType = MainScheduler.instance,
                            with decoder: JSONDecoder = .default) -> Single<T> {
        
        return self
            .asObservable()
            .map { response in
                do {
                    return try decoder.decode(T.self, from: response.data)
                } catch {
                    let decodErr = DecodeError(error: error, response: response, targetTypeDescription: T.self)
                    APICoreManager.shared.requestHttpErrorsPublisher.onNext(decodErr)
                    throw error
                }
        }
        .asSingle()
            .observeOn(scheduler)
    }
    
    
    func mapTo<T:Decodable>(on scheduler: ImmediateSchedulerType = MainScheduler.instance,
                            with decoder: JSONDecoder = .default) -> Single<T> {
        
        return self
            .asObservable()
            .map { response in
                do {
                    return try decoder.decode(T.self, from: response.data)
                } catch {
                    let decodErr = DecodeError(error: error, response: response, targetTypeDescription: T.self)
                    APICoreManager.shared.requestHttpErrorsPublisher.onNext(decodErr)
                    throw error
                }
            }
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
    
    func mapWithRedirectTo<T:Decodable>(_ type: T.Type,
                                        on scheduler: ImmediateSchedulerType = MainScheduler.instance,
                                        with decoder: JSONDecoder = .default) -> Single<(data:T, redirect: MethodRedirect)> {
        return self
            .asObservable()
            .map { response in
                do {
                    let data = try decoder.decode(T.self, from: response.data)
                    let redirect = try MethodRedirect(response.response)
                    return (data: data, redirect: redirect)
                } catch {
                    let decodErr = DecodeError(error: error, response: response, targetTypeDescription: T.self)
                    APICoreManager.shared.requestHttpErrorsPublisher.onNext(decodErr)
                    throw error
                }
        }
        .asSingle()
            .observeOn(scheduler)
    }
    
    func mapWithRedirectIfHasTo<T:Decodable>(_ type: T.Type,
                                             on scheduler: ImmediateSchedulerType = MainScheduler.instance,
                                             with decoder: JSONDecoder = .default) -> Single<(data:T, redirect: MethodRedirect?)> {
        return self
            .asObservable()
            .map { response in
                do {
                    let data = try decoder.decode(T.self, from: response.data)
                    let redirect = try? MethodRedirect(response.response)
                    return (data: data, redirect: redirect)
                } catch {
                    let decodErr = DecodeError(error: error, response: response, targetTypeDescription: T.self)
                    APICoreManager.shared.requestHttpErrorsPublisher.onNext(decodErr)
                    throw error
                }
        }
        .asSingle().observeOn(scheduler)
    }
    
    func mapToRedirect(on scheduler: ImmediateSchedulerType = MainScheduler.instance) -> Single<MethodRedirect> {
        return self
            .asObservable()
            .map { try MethodRedirect($0.response) }
            .asSingle()
            .observeOn(scheduler)
    }
}


