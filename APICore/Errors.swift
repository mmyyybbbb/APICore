//
//  APICoreError.swift
//  APICore
//
//  Created by alexej_ne on 30/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import Moya

func fatal(_ text: String) -> Never {
    fatalError("APICore[fatal]: \(text)")
}

func error(_ text: String) {
    fatalError("APICore[error]: \(text)")
}

/// Базовый класс ошибки возвращаемый APICore
public struct ApiCoreRequestError: Error, Traceble {
    
    public init(error: Error) {
        self.originErorr = error
        if let moyaError = error as? MoyaError {
            self.moyaError = moyaError
            self.traceId = moyaError.response?.request?.traceId ?? ""
            self.owner = moyaError.response?.request?.owner
            self.scope = moyaError.response?.request?.owner
            self.url = moyaError.response?.response?.url
            let nsError =   moyaError.asNSError
            self.originNSError =  nsError.asAFError?.underlyingError?.asNSError ?? nsError
            self.response = moyaError.response
            self.statusCode = moyaError.response?.statusCode
            self.localizedDescription = originNSError.localizedDescription
        } else {
            self.moyaError = nil
            self.traceId = ""
            self.owner = nil
            self.scope = nil
            self.url = nil
            self.originNSError = error.asNSError
            self.response = nil
            self.statusCode = nil
            self.localizedDescription = error.localizedDescription
        }
    }
    
    /// Moya оборачивает ошибки в MoyaError
    internal let moyaError: MoyaError?
    /// Разворачиваем MoyaError и AFError (Alamofire) до оригинально ошибки брошенной URLRequest
    public let originNSError: NSError
    /// Ошибка которая обернута в ApiCoreError
    public let originErorr: Error
    /// уникальный id запроса добавляется как header к запросу плагином Tracer
    public let traceId: String
    /// Владелец метода  запроса добавляется как header к запросу плагином Tracer
    public let owner: String?
    /// Скоуп  метода  запроса добавляется как header к запросу плагином Tracer
    public let scope: String?
    /// URL на который был выполнен запрос
    public let url: URL?
    /// Модель респонса из Moya
    public let response: Response?
    /// HTTP Status code
    public let statusCode: Int?
    /// Человеческое описание ошибки
    public let localizedDescription: String
    /// Домен ошибки ( обычно тут NSURLErrorDomain)
    public var domain: String { originNSError.domain }
    /// Код ошибки для домена domen
    public var code: Int  { originNSError.code }
}

public extension ApiCoreRequestError {
    /// Ошибка: отсутсвует интернет
    var isNotInternetConnectionError: Bool { code == NSURLErrorNotConnectedToInternet }
    /// Ошибка: ресурс не найден 404
    var isHTTPResourceNotFounde404: Bool { response?.statusCode == 404 }
    /// Ошибка: не найден хост
    var isHostNotFound: Bool { code == NSURLErrorCannotFindHost }
    
    var debugText: String {
        var result = self.localizedDescription
        if let url = url {
            result += "\nurl: \(url.absoluteString)"
        }
        result += "\ntraceId: \(traceId)"
        
        if let headers = moyaError?.response?.request?.headers {
            for h in headers.dictionary {
                result += "\n[\(h)]: \(h.value)"
            }
        }
        return result
    }
}

/// Ошибка парсинга данных
public struct ApiCoreDecodingError: Error, Traceble  {
    
    public init(decodingError: DecodingError, targetType: Any, traceId: String, owner:String? = nil, scope: String? = nil,  data: String, response: Response? = nil) {
        self.decodingError = decodingError
        self.targetType = targetType
        self.traceId = traceId
        self.data = data
        self.response = response
        self.statusCode = response?.statusCode
        self.owner = owner
        self.scope = scope
    }
    
    init?(moyaError: MoyaError, targetType: Any) {
        guard let decodingError = moyaError.originError as? DecodingError else { return nil }
        self.decodingError = decodingError
        self.targetType = targetType
        guard let resp = moyaError.response else { return nil  }
        self.data = String(data: resp.data, encoding: .utf8) ?? "cant decode with utf8"
        self.traceId =  resp.request?.traceId ?? ""
        self.scope = resp.request?.scopeName
        self.owner = resp.request?.owner
        self.response = moyaError.response
        self.statusCode = moyaError.response?.statusCode
    }
    
    init?(error: Error, response: Response, targetType: Any) {
        if let moyaError = error as? MoyaError {
            self.init(moyaError: moyaError, targetType: targetType)
        } else if let decodingError = error as? DecodingError {
            self.init(decodingError: decodingError,
                      targetType: targetType,
                      traceId: response.request?.traceId ?? "",
                      owner: response.request?.owner,
                      scope: response.request?.scopeName,
                      data: String(data: response.data, encoding: .utf8) ?? "cant decode with utf8",
                      response: response)
        } else {
            return nil
        } 
    }
    
    public let decodingError: DecodingError
    public let targetType: Any
    public let traceId: String
    public let owner: String?
    public let scope: String?
    public var targetTypeName: String { String(describing: targetType) }
    public let data: String
    public let statusCode: Int?
    public let response: Response?
}

public extension MoyaError {
    var originError: Error? {
        switch self {
        case .imageMapping: return nil
        case .jsonMapping: return nil
        case .stringMapping: return nil
        case .objectMapping(let error, _): return error
        case .encodableMapping(let error): return error
        case .statusCode: return nil
        case .underlying(let error, _): return error
        case .requestMapping: return nil
        case .parameterEncoding(let error): return error
        }
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
    
    var asApiCoreDecodingError: ApiCoreDecodingError? { self as? ApiCoreDecodingError }
    var asApiCoreError: ApiCoreRequestError? { self as? ApiCoreRequestError}
}
