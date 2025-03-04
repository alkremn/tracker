//
//  WeekDay.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/17/25.
//

import Foundation

enum WeekDay: Int, CaseIterable, Comparable, Codable {
   case Monday = 1, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
    
    var fullName: String {
        switch self {
        case .Monday:
            return "Понедельник"
        case .Tuesday:
            return "Вторник"
        case .Wednesday:
            return "Среда"
        case .Thursday:
            return "Четверг"
        case .Friday:
            return "Пятница"
        case .Saturday:
            return "Суббота"
        case .Sunday:
            return "Воскресенье"
        }
    }
    
    var shortName: String {
        switch self {
        case .Monday:
            return "Пн"
        case .Tuesday:
            return "Вт"
        case .Wednesday:
            return "Ср"
        case .Thursday:
            return "Чт"
        case .Friday:
            return "Пт"
        case .Saturday:
            return "Сб"
        case .Sunday:
            return "Вс"
        }
    }
    
    static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
