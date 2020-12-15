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

public typealias APICoreResponse = Response

open class RequestBuilder<S: APIServiceType>  {
    
    private let method: S.Method
    
    public init(_ type: S.Type, _ method: S.Method) {
        self.method = method
    }
    
    public func request() -> Single<Response> {
        
        if let behavior = S.configurator.requestsErrorBehavior {
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
        
        let notifyAboutError: (Error) -> Void = { APICoreManager.shared.requestHttpErrorsPublisher.onNext($0) }
        
        func req() -> Single<Response> {
            
            let baseReq = S.shared.provider.rx
                .request(method, callbackQueue: DispatchQueue.global())
                .catchError { throw ApiCoreRequestError(error: $0) }
            
            if case AuthStrategy.withoutAuth = S.shared.authStrategy   {
                return baseReq
            } else {
                return Single.just(()).flatMap { () -> Single<Response> in
                    let configurator = S.configurator
                    guard let delegate = configurator.delegate else { return baseReq }
                    if delegate.isTokenValid {
                        return baseReq
                    } else {
                        return delegate.refreshToken().flatMap { baseReq }
                    }
                }
            }
        }
        
        let configurator = S.configurator
        
        if let delegate = configurator.delegate {
            
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
            
            return req().flatMap(tryRestoreAccess).map(notifyUnauthorized).do(onError: notifyAboutError)
        } else {
            return req().do(onError: notifyAboutError)
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

func publish(_ error: Error) {
    APICoreManager.shared.requestHttpErrorsPublisher.onNext(error)
}

public extension APICoreResponse {
    /// Метод для парсинга запроса в модель. В случае ошибки парсинга бросает ApiCoreDecodingError, а также отправляет уведомление в APICoreManager.shared.requestHttpErrorsPublisher.onNext
    func decode<D: Decodable>(_ type: D.Type, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder()) throws -> D {
        do {
            return try  map(type, atKeyPath: keyPath, using: decoder, failsOnEmptyData: true)
        } catch {
            let errorForThrow = ApiCoreDecodingError(error: error, response: self, targetType: D.self) ?? error
            publish(errorForThrow)
            throw errorForThrow
        }
    }
}

public extension Single where Element == Response {
    
    
    func mapTo<T:Decodable>(_ type: T.Type, on scheduler: ImmediateSchedulerType = MainScheduler.instance,
                            with decoder: JSONDecoder = .default) -> Single<T> {
        asObservable()
            .map { try $0.decode(type, using: decoder)  }
            .asSingle()
            .observeOn(scheduler)
    }
    
    
    func mapTo<T:Decodable>(on scheduler: ImmediateSchedulerType = MainScheduler.instance,
                            with decoder: JSONDecoder = .default) -> Single<T> {
        asObservable()
            .map { try $0.decode(T.self, using: decoder)  }
            .asSingle()
            .observeOn(scheduler)
    }
    
    func mapToVoid(on scheduler: ImmediateSchedulerType = MainScheduler.instance) -> Single<Void> {
        asObservable()
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
                    let data = try response.map(type, atKeyPath: nil, using: decoder, failsOnEmptyData: true)
                    let redirect = try MethodRedirect(response.response)
                    return (data: data, redirect: redirect)
                } catch {
                    let errorForThrow = ApiCoreDecodingError(error: error, response: response, targetType: T.self) ?? error
                    publish(errorForThrow)
                    throw errorForThrow
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
                    let data = try response.map(type, atKeyPath: nil, using: decoder, failsOnEmptyData: true)
                    let redirect = try? MethodRedirect(response.response)
                    return (data: data, redirect: redirect)
                } catch {
                    let errorForThrow = ApiCoreDecodingError(error: error, response: response, targetType: T.self) ?? error
                    publish(errorForThrow)
                    throw errorForThrow
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



public extension PrimitiveSequence where Trait == SingleTrait, Element == APICoreResponse {
    
    func convertToAPICoreErrorIfCatch() -> PrimitiveSequence<SingleTrait, APICoreResponse> {
        self.catchError { err in
            let apiCoreErr = ApiCoreRequestError(error: err)
            publish(apiCoreErr)
            throw apiCoreErr
        }
    }
    
    
    /// Filters out responses that don't fall within the given range, generating errors when others are encountered.
    func apiCoreFilter<R: RangeExpression>(statusCodes: R) -> Single<Element> where R.Bound == Int {
        map { try $0.filter(statusCodes: statusCodes)}
            .convertToAPICoreErrorIfCatch()
    }
    
    /// Filters out responses that has the specified `statusCode`.
    func apiCoreFilter(statusCode: Int) -> Single<Element> {
        map { try $0.filter(statusCode: statusCode)}
            .convertToAPICoreErrorIfCatch()
    }
    
    
    /// Filters out responses where `statusCode` falls within the range 200 - 299.
    func apiCoreFilterSuccessfulStatusCodes() -> Single<Element> {
        map { try $0.filterSuccessfulStatusCodes()}
            .convertToAPICoreErrorIfCatch()
    }
    
    
    /// Filters out responses where `statusCode` falls within the range 200 - 399
    func apiCoreFilterSuccessfulStatusAndRedirectCodes() -> Single<Element> {
        map { try $0.filterSuccessfulStatusAndRedirectCodes()}
            .convertToAPICoreErrorIfCatch()
        
    }
}
