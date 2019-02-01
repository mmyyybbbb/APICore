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

class APICoreTests: XCTestCase {
    
    override func setUp() {
        APICoreObjectContainer.instanceLazyInit.register(ReqresServicesConfigurator())
    }
    
    override func tearDown() {
        APICoreObjectContainer.releaseInstance()
    }
 
    func test_customConfigurationForService() {
        // запрос должен отвалиться потомучту мы переопределим конфигурацию для сервиса и укажем в ней некорректный url
        let configurator = ReqresServicesConfigurator(baseUrl: "https://reqres2222222.in") // плохой url
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
    
    func test_simpleRequest() {
        
        do {
            let request:Single<Response<User>> = RequestBuilder(ReqresUserAPI.self, .single(id: 2)).map()
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
            
            let request:Single<Response<User>> = RequestBuilder(ReqresUserAPI.self, .single(id: 2)).map()
            let result = try request.toBlocking().first()
            XCTAssertEqual(result?.data.id, 222, "NO mocks")
        } catch {
            XCTFail("Catched error: \(error)")
        }
    }

}

