//
//  String+Ext.swift
//  Tracker
//
//  Created by Alexey Kremnev on 3/12/25.
//

import Foundation

extension String {
    func toWeekDayArray() -> [WeekDay] {
        self.split(separator: ",").map{ WeekDay(rawValue: Int($0) ?? 1) ?? .monday }
    }
}
