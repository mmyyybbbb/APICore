//
//  Date+.swift
//  APICore
//
//  Created by alexej_ne on 17.07.2019.
//  Copyright © 2019 BCS. All rights reserved.
//

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
