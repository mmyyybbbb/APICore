//
//  MimeType.swift
//  APICore
//
//  Created by alexej_ne on 31/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

public enum BinaryData {
    case jpeg(Data)
    case custom(Data, mimeType: String?, key: String, fileName: String?)
    
    public var name: String {
        switch self {
        case .jpeg(_): return "file"
        case .custom(_, _, let key, _): return key
        }
    }
    
    public var mimeType: String? {
        switch self {
        case .jpeg: return "image/jpeg"
        case .custom(_, let mimeType, _, _): return mimeType
        }
    }
    
    public var data: Data {
        switch self {
        case .jpeg(let data): return data
        case .custom(let data, _, _, _): return data
        }
    }
    
    public var fileName: String? {
        switch self {
        case .jpeg(_): return "file.jpg"
        case .custom(_, _, _, let filename): return filename
        }
    }
}
