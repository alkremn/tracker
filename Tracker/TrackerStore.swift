//
//  TrackerStore.swift
//  Tracker
//
//  Created by Alexey Kremnev on 3/1/25.
//

import Foundation
import CoreData

final class TrackerStore {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
//    convenience init() {
//        CoreDataStack.shared.viewContext
//    }
    
    func addNewTracker() throws {
        
        
        try context.save()
    }
}
