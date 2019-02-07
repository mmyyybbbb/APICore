//
//  APICoreError.swift
//  APICore
//
//  Created by alexej_ne on 30/01/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

func fatal(_ text: String) -> Never {
    fatalError("APICore[fatal]: \(text)")
}

func error(_ text: String) {
    fatalError("APICore[error]: \(text)")
}
