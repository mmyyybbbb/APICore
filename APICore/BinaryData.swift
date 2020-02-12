//
//  MimeType.swift
//  APICore
//
//  Created by alexej_ne on 31/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

public enum BinaryData {
    case jpeg(Data)
    case custom(Data, mimeType: String)
    case customName(Data, mimeType: String?, key: String)
    
    public var name: String {
        switch self {
        case .customName(_, _, let key): return key
        default: return "file"
        }
    }
    
    public var fileName: String? {
        switch self {
        case .jpeg: return "file.jpg"
        default: return nil
        }
    }
    
    public var mimeType: String? {
        switch self {
        case .jpeg: return "image/jpeg"
        case .custom(_, let str): return str
        case .customName(_, let mimeType, _): return mimeType
        }
    }
    
    public var data: Data {
        switch self {
        case .jpeg(let data): return data
        case .custom(let data, _): return data
        case .customName(let data, _, _): return data
        }
    }
}
