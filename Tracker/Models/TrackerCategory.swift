//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/4/25.
//

import Foundation

struct TrackerCategory {
    let id: UUID
    let title: String
    let trackers: [Tracker]
}
