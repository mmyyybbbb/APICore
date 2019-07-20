//
//  PluginType+.swift
//  APICore
//
//  Created by Alexej Nenastev on 20.07.2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import Moya

public extension PluginType {
    static var logger: PluginType { return Plugins.logger() }
}
