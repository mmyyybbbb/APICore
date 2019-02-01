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
    
    public var mimeType: String {
        switch self {
        case .jpeg: return "image/jpeg"
        case .custom(_ ,let str): return str
        }
    }
    
    public var data: Data {
        switch self {
        case .jpeg(let data): return data
        case .custom(let data , _): return data
        }
    }
}
