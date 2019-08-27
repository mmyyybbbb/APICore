//
//  APIService.swift
//  APICore
//
//  Created by alexej_ne on 28/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import Moya

open class APIService<TMethod, TConfigurator>: APIServiceType where TMethod: APIServiceMethod, TConfigurator: APIServiceConfiguratorType   {
 
    public typealias Method = TMethod
    public typealias Configurator = TConfigurator
    private var actualMocks: [Method.MockKey: Data] = [:]
    open var allServiceBodyEncoding: MethodBodyEncoding?
    open var useMocksIfSetted: Bool = true
    open var urlServicePathComponent: String { return "" }
    open var serviceHeaders:[String: String]? { return nil }
    open var authStrategy: AuthStrategy { return .withoutAuth }
    
    private var configuratorStrong: Configurator {
        guard let serviceConfigurator = APIService<TMethod, TConfigurator>.configurator else {
            fatal("ServiceConfigurator is nil")
        }
        return serviceConfigurator
    }
    
    lazy public var provider: MoyaProvider<TMethod> = {
        let configurator = configuratorStrong
        var plugins = configurator.plugins
        
        if case AuthStrategy.authorizationHeader = self.authStrategy,
            configurator.plugins.contains(where: { $0 is AccessTokenPlugin}) == false {
            let accessPlugin = AccessTokenPlugin(tokenClosure: { [weak configurator] in
                return configurator?.delegate?.token ?? ""
            })
            plugins.append(accessPlugin)
        }
        
        return MoyaProvider<TMethod>(endpointClosure: endpointBuilder,
                                     stubClosure: stubBehaviorBuilder,
                                     manager: configurator.sessionManager,
                                     plugins: plugins)
 
    }()
    
    required public init() {}
}

//MARK: Public+
public extension  APIService {
    var authTokenProvided: Bool {
        guard let serviceConfigurator = APIService<TMethod, TConfigurator>.configurator else {
            return false
        }
        return serviceConfigurator.delegate?.token != nil
    }
    
    func setMock(for key: Method.MockKey, value: String) {
        if let data = value.data(using: .utf8) {
            actualMocks[key] = data
        }
    }
    
    func setMock(for key: Method.MockKey, value: Data) {
        actualMocks[key] = value
    }
    
    func removeMock(for key: Method.MockKey) {
        actualMocks.removeValue(forKey: key)
    }
    
    func mockData(for key: Method.MockKey) -> Data? {
        return actualMocks[key]
    }
    
    func isMocked(_ key: Method.MockKey) -> Bool {
        return actualMocks.keys.contains(key)
    }
}

//MARK: Public+
public extension APIService where TMethod.MockKey: MockSampleData {
    public func setMockFromSample(for key: Method.MockKey) {
        guard let sample = key.sampleData else { return }
        setMock(for: key, value: sample)
    }
}

//MARK: Private
fileprivate extension APIService {
    
    func endpointBuilder(_ method: Method) -> Endpoint {
        
        let fullUrl = buildFullUrl(method)
        let fullHeaders = buildFullHeader(method)
        let mockClosure = buildMockClosure(method)
        
        return Endpoint(url: fullUrl.absoluteString,
                        sampleResponseClosure: mockClosure,
                        method: method.methodPath.httpMethod,
                        task: buildTask(method),
                        httpHeaderFields: fullHeaders)
        
    }
    
    func buildTask(_ method: Method) -> Task {
        var methodParams = method.params
        print("url: \(authStrategy)")
        
        if case let AuthStrategy.addTokenToUrl(urlParamName: authUrlTokenKey) = authStrategy,
           let token = configuratorStrong.delegate?.token {
            methodParams.url(authUrlTokenKey, token)
        }
        
        if let multipartData = method.multipart {
            let formData = MultipartFormData(provider: .data(multipartData.data),
                                             name: "file",
                                             fileName: "file.jpg",
                                             mimeType: multipartData.mimeType)
            return .uploadCompositeMultipart([formData], urlParameters: methodParams.urlParams)
        }
        
        if methodParams.bodyParams.isEmpty {
            return .requestParameters(parameters: methodParams.urlParams, encoding: URLEncoding.queryString)
        }
        
        return .requestCompositeParameters(bodyParameters: methodParams.bodyParams,
                                           bodyEncoding: getBodyEncoding(method),
                                           urlParameters: methodParams.urlParams)
    }
    
    func getBodyEncoding(_ method: Method) -> BodyEncoding {
        if let methodBodyEncoding = method.overrideBodyEncoding {
            return methodBodyEncoding
        }
        
        let httpMethod = method.methodPath.httpMethod
        if let allServiceBodyEncoding = allServiceBodyEncoding {
            return allServiceBodyEncoding(httpMethod)
        }
        
        return configuratorStrong.bodyEncoding(httpMethod)
    }
    
    func buildFullHeader(_ method: Method) -> [String: String] {
        var fullHeaders: [String: String] = configuratorStrong.baseHeaders ?? [:]
        
        if let serviceHeaders = serviceHeaders {
            fullHeaders = fullHeaders.merging(serviceHeaders,
                                              uniquingKeysWith: {( _, serv) in serv })
        }
        
        if let methodHeaders = method.headers {
            fullHeaders = fullHeaders.merging(methodHeaders,
                                              uniquingKeysWith: {( _, meth) in meth })
        }
        
        print("header: \(authStrategy)")
        if case let AuthStrategy.addTokenToHeader(headerName: headerTokenKey) = authStrategy,
            let token = configuratorStrong.delegate?.token {
            fullHeaders[headerTokenKey] = token 
        }
        
        return fullHeaders
    }
    
    func buildMockClosure(_ method: Method) -> Endpoint.SampleResponseClosure {
        return { [weak self] in
            guard let key = method.mockKey, let data = self?.actualMocks[key] else {
                return .networkResponse(200, method.sampleData)
            }
            
            return .networkResponse(200, data)
        }
    }
    
    private func stubBehaviorBuilder(_ method: Method) -> StubBehavior {
        guard useMocksIfSetted, let key = method.mockKey else { return .never }
        return actualMocks.keys.contains(key) ? .delayed(seconds: 1) : .never
    }
    
    
    private func buildFullUrl(_ method: Method) -> URL {
        
        // Когда путь метода начинается с "/", то относительный путь в базовом урл игнорируется
        //
        // Например:
        // - базовой урл: "https://my.broker.ru/services"
        // - путь метода: "/services/api/v1/accounts/iia/agreements/9ddc90c0-bed6-4bae-a87b-8a285ab7c6c9/status"
        // - конечный урл: "https://my.broker.ru/services/api/v1/accounts/iia/agreements/9ddc90c0-bed6-4bae-a87b-8a285ab7c6c9/status"
        //
        // то есть, не будет повторяться 2 раза /services/serivces
        //
        if method.methodPath.path.starts(with: "/") {
            let baseUrl = configuratorStrong.baseUrl
            let relativePath = configuratorStrong.baseUrl.relativePath
            let host = baseUrl.absoluteString.replacingOccurrences(of: relativePath, with: "")
            
            if let baseUrl = URL(string: host) {
                return baseUrl.appendingPathComponent(method.methodPath.path)
            }
        }
        
        return configuratorStrong.baseUrl
            .appendingPathComponent(urlServicePathComponent)
            .appendingPathComponent(method.methodPath.path)
    }
}
