//
//  Pluggins.swift
//  APICore
//
//  Created by alexej_ne on 31/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import Moya

public final class Plugins {
    
    public static let logger = NetworkLoggerPlugin(configuration: .default)
    
    public static let tracer = Tracer()
}

public extension NetworkLoggerPlugin.Configuration {
    static let `default` = NetworkLoggerPlugin.Configuration()
}
 
public final class Tracer: PluginType {

    public struct Key {
        public static let traceId = "x-traceId"
        public static let owner = "x-owner"
        public static let scope = "x-scope"
    }
    
    public static var additionalTraceHeaders: [String: String] = [:]
    
    public static var sendMethodOwner: Bool = false
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        request.addValue(UUID.init().uuidString, forHTTPHeaderField: Tracer.Key.traceId)
        if Tracer.sendMethodOwner, let metaInfo = target as? MethodMeta {
            request.addValue(metaInfo.owner.owner, forHTTPHeaderField: Tracer.Key.owner)
            request.addValue(metaInfo.owner.scopeName, forHTTPHeaderField: Tracer.Key.scope)
        }
        for traceParam in Tracer.additionalTraceHeaders {
            request.addValue(traceParam.value, forHTTPHeaderField: traceParam.key)
        }
        return request
    }
}

public protocol Traceble {
    var traceId: String { get }
}

extension URLRequest: Traceble {
    /// уникальный id запроса добавляется как header к запросу плагином Tracer
    public var traceId: String { allHTTPHeaderFields?[Tracer.Key.traceId] ?? "" }
    public var scopeName: String? { allHTTPHeaderFields?[Tracer.Key.scope] }
    public var owner: String? { allHTTPHeaderFields?[Tracer.Key.owner] }
}

 
public extension NetworkLoggerPlugin.Configuration {
    static func apiCore(output: @escaping OutputType = NetworkLoggerPlugin.Configuration.defaultOutput(target:items:),
                        options: LogOptions = .default) -> NetworkLoggerPlugin.Configuration {

        .init(formatter: Formatter(entry: NetworkLoggerPlugin.Configuration.Formatter.APICore.entryFormatter,
                                   requestData: NetworkLoggerPlugin.Configuration.Formatter.APICore.dataFormatter,
                                   responseData: NetworkLoggerPlugin.Configuration.Formatter.APICore.dataFormatter),
              output: output,
              logOptions: options)
    }
}

public extension NetworkLoggerPlugin.Configuration.Formatter {
    
    struct APICore {
        
        public static let dataFormatter: DataFormatterType = {
            func dataFormatter(_ data: Data) -> String {
                do {
                    let dataAsJSON = try JSONSerialization.jsonObject(with: data)
                    let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
                    return String(data: prettyData, encoding: .utf8) ?? "## Cannot map data to String ##"
                } catch {
                    return String(data: data, encoding: .utf8) ?? "## Cannot map data to String ##"
                }
            }
            return dataFormatter(_:)
        }()
        
        public static let dateFormatter: DateFormatter = {
            let df = DateFormatter()
            df.dateFormat = "HH:MM:SS"
            let dateStr = df.string(from: Date())
            return df
        }()
        
        public static let entryFormatter: EntryFormatterType = {
             func entryFormatter(identifier: String, message: String, target: TargetType) -> String {
                var mess = ""
                switch identifier {
                case "Request Headers":
                    var ms = message
                    ms.removeFirst()
                    ms.removeLast()
                    return ms.replacingOccurrences(of: ",", with: "\n").replacingOccurrences(of: "\"", with: "")
                default:
                    mess = message
                }
                return "API: [\(dateFormatter.string(from: Date()))] \(identifier): \(mess)"
            }
            return entryFormatter(identifier:message:target:)
        }()
    }
}
 
