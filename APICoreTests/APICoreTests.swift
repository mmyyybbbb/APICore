//
//  APICoreTests.swift
//  APICoreTests
//
//  Created by alexej_ne on 28/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

@testable import APICore
import XCTest
import RxSwift
import RxBlocking
import Moya

class APICoreTests: XCTestCase, AuthTokenProvider {
    
    override func setUp() {
        let config = ReqresServicesConfigurator()
        config.authTokenProvider = self
        APICoreObjectContainer.instanceLazyInit.register(config)
    }
    
    let bag = DisposeBag()
    
    var token: AuthToken? = "token"
    
    override func tearDown() {
        APICoreObjectContainer.releaseInstance()
    }
 
    func test_customConfigurationForService() {
        // запрос должен отвалиться потомучту мы переопределим конфигурацию для сервиса и укажем в ней некорректный url
        let configurator = ReqresServicesConfigurator(baseUrl: "https://my.broker2.ru") // плохой url
        APICoreObjectContainer.instanceLazyInit.register(configurator: configurator, for: ReqresUserAPI.self)
        
        let request = RequestBuilder(ReqresUserAPI.self, .single(id: 2)).request()
        let result = request.toBlocking().materialize()
        
        switch result {
        case .completed: XCTFail("No expected result")
        case let .failed(_, error):
            
            guard case MoyaError.underlying(let err, _) = error else  {
                XCTFail("No expected result")
                return
            }
            
            XCTAssertEqual((err as NSError).domain, "NSURLErrorDomain", "")
        }
    }
    
    func test_noInternetConnection() {
        let configurator = ReqresServicesConfigurator(baseUrl: "https://google.com")
        APICoreObjectContainer.instanceLazyInit.register(configurator: configurator, for: ReqresUserAPI.self)
        
        let behavior: RequestBuilderErrorBehavior = .autoRepeatWhen(nsUrlErrorDomainCodeIn: [NSURLErrorNotConnectedToInternet],
                                                                    maxRepeatCount: 3,
                                                                    repeatAfter: 5)
        
        APICoreManager.shared.requestHttpErrors
            .subscribe(onNext: { error in print("[GET] \(error)") })
            .disposed(by: bag)
        
        let request = RequestBuilder(ReqresUserAPI.self, .single(id: 2)).request(onErrorBehavior: behavior)
        let result = request.toBlocking().materialize()
        
        
        switch result {
        case .completed:
            XCTFail("No expected result")
        case let .failed(_, error):
            
            guard case MoyaError.underlying(let err, _) = error else  {
                XCTFail("No expected result")
                return
            }
            XCTAssertEqual((err as NSError).domain, "NSURLErrorDomain", "")
        }
    }
    
    func test_simpleRequest() {
        
        do {
            let request:Single<Response<User>> = RequestBuilder(ReqresUserAPI.self, .single(id: 2)).requestWithMap()
            let result = try request.toBlocking().first()
            XCTAssertNotNil(result, "Data model is nil")
        } catch {
            XCTFail("Catched error: \(error)")
        }
    }
    
    func test_mockableRequest() {
        do {
            let response = """
            {
            \"data\" : {
            \"id\" : 222,
            \"last_name\" : \"Weaver\",
            \"first_name\" : \"Janet\",
            \"avatar\" : \"\"
            }
            }
            """
            ReqresUserAPI.shared.useMocksIfSetted = true
            ReqresUserAPI.shared.setMock(for: .single, value: response)
            
            let request:Single<Response<User>> = RequestBuilder(ReqresUserAPI.self, .single(id: 2)).requestWithMap()
            let result = try request.toBlocking().first()
            XCTAssertEqual(result?.data.id, 222, "NO mocks")
        } catch {
            XCTFail("Catched error: \(error)")
        }
    }

}

