//
//  String+.swift
//  BrokerAPIServices
//
//  Created by Ponomarev Vasiliy on 27/03/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import Alamofire

public extension String {
    func asUrlWithSharpEncoding(parameters: [String: Any]? = nil) -> URL {
        let tempURLRequest = URLRequest(url: URL(string: self)!)
        let r = try! URLEncoding.queryString.encode(tempURLRequest, with: parameters)
        let s = r.url!.absoluteString
        return URL(string: s.replacingOccurrences(of: "?", with: "#"))!
    }

}
