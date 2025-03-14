//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Alexey Kremnev on 3/4/25.
//

import Foundation
import CoreData

struct TrackerRecordStoreModel {
    let trackerId: UUID
    let date: Date
}

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        self.init(context: CoreDataStack.shared.viewContext)
    }
    
    func add(model: TrackerRecordStoreModel, tracker: TrackerCoreData) throws {
        guard let records = tracker.records as? Set<TrackerRecordCoreData> else { return }
        
        let record = records.first(where: { $0.date == model.date })
        if let record {
            tracker.removeFromRecords(record)
        } else {
            let trackerRecordCoreData = TrackerRecordCoreData(context: tracker.managedObjectContext ?? context)
            trackerRecordCoreData.date = model.date
            trackerRecordCoreData.tracker = tracker
        }
        
        try context.save()
    }
}
