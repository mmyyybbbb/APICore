//
//  ReqresAPI.swift
//  APICoreTests
//
//  Created by alexej_ne on 31/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import APICore

final class ReqresUserAPI: APIService<ReqresUserMethods, ReqresServicesConfigurator>  {
    
    override var urlServicePathComponent: String { return "/api/" }
    
}
