//
//  APICoreTests.swift
//  APICoreTests
//
//  Created by alexej_ne on 28/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

@testable import APICore
import XCTest
import Moya
import Alamofire
import RxSwift
import RxBlocking

class APICoreTests: XCTestCase {
    
    override func setUp() {
        APICoreObjectContainer.instanceLazyInit.register(ReqresServicesConfigurator())
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

