//
//  AuthorizationStrategy.swift
//  APICore
//
//  Created by alexej_ne on 06/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

public enum AuthStrategy {
    case withoutAuth
    case addTokenToHeader(headerName: String)
    case addTokenToUrl(urlParamName: String)
}
