//
//  Tracker.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/4/25.
//

import Foundation

struct Tracker {
    let id: UUID
    let name: String
    let hexColor: String
    let icon: String
    let schedule: [WeekDay]?
}
