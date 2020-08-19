//
//  DataRequest.swift
//  APICore
//
//  Created by alexej_ne on 28/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import Moya
import Alamofire
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
        
        let notifyAboutError: (Error) -> Void = { APICoreManager.shared.requestHttpErrorsPublisher.onNext($0.asNSError) }
        
        func req() -> Single<Response> {
            S.shared.provider.rx
                .request(method, callbackQueue: DispatchQueue.global())
                .do(onError: notifyAboutError)
        }
        
        if let delegate = S.configurator?.delegate, let configurator = S.configurator {
            
            func tryRestoreAccess(response: Response) -> Single<Response> {
                guard configurator.isNeedTryRestoreAccess, configurator.isUnauthorized(response: response) else { return .just(response) }
                return delegate.tryRestoreAccess(response: response).flatMap { req() }
            }
            
            func notifyUnauthorized(response: Response) -> Response {
                if configurator.isUnauthorized(response: response) {
                    APICoreManager.shared.requestUnauthorizedPublisher.onNext(response)
                }
                return response
            }
            
            return req().flatMap(tryRestoreAccess).map(notifyUnauthorized)
        } else {
            return req()
        }
    }
    
    private func  onCatchError(behavior: RequestErrorBehavior, error: Error) throws  -> Single<Response> {
        let nsError = error.asNSError
        
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
 
public extension Error {
    var asNSError: NSError {
        let error: Error = self
        if case MoyaError.underlying(let err, _) = error  {
            return err as NSError
        }
        return error as NSError
    }
    
    func `is`(domain: String, code: Int) -> Bool {
        let err = asNSError
        return err.domain == domain && err.code == code
    }
    
    var isNotConnectedToInternetError: Bool {
        if self.is(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet) { return true }
        if let afError = self as? AFError {
            debugPrint(afError)
        }
        return false
    }
}
 
/// Ошибка парсинга данных
public struct DecodeError: ApiCoreError {
    public let error: Error
    public let response: Response?
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
                    let decodeErr = DecodeError(error: error, response: response, targetTypeDescription: T.self)
                    APICoreManager.shared.requestHttpErrorsPublisher.onNext(decodeErr)
                    throw decodeErr
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
                    let decodeErr = DecodeError(error: error, response: response, targetTypeDescription: T.self)
                    APICoreManager.shared.requestHttpErrorsPublisher.onNext(decodeErr)
                    throw decodeErr
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
                    let decodeErr = DecodeError(error: error, response: response, targetTypeDescription: T.self)
                    APICoreManager.shared.requestHttpErrorsPublisher.onNext(decodeErr)
                    throw decodeErr
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
                    let decodeErr = DecodeError(error: error, response: response, targetTypeDescription: T.self)
                    APICoreManager.shared.requestHttpErrorsPublisher.onNext(decodeErr)
                    throw decodeErr
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

public extension Response {
    /// уникальный id запроса добавляется как header к запросу плагином Tracer
    var traceId: String? { request?.allHTTPHeaderFields?[Tracer.Key.traceId] }
}

/// Ошибка взаимодействия с внешним API
public protocol ApiCoreError: Error {
    /// уникальный id запроса добавляется как header к запросу плагином Tracer
    var traceId: String? { get }
    var response: Response? { get }
}

public extension ApiCoreError {
    /// уникальный id запроса добавляется как header к запросу плагином Tracer
    var traceId: String? { response?.traceId }
    
    var responseHeaders: [AnyHashable: Any]? { response?.response?.allHeaderFields }
    
    var url: URL? { response?.response?.url }
    
    var debugText: String {
        var result = self.localizedDescription
        if let url = url {
            result += "\nurl: \(url.absoluteString)"
        }
        if let traceId = traceId {
            result += "\ntraceId: \(traceId)"
        }
        
        if let headers = responseHeaders {
            for h in headers {
                result += "\n[\(h.key)]: \(h.value)"
            }
        }
        return result
    }
}

extension MoyaError: ApiCoreError {
    
}
