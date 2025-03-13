//
//  Date+Ext.swift
//  Tracker
//
//  Created by Alexey Kremnev on 3/12/25.
//

import Foundation


extension Date {
    var localDate: Date {
        self.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
    }
}
