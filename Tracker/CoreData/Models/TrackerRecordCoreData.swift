//
//  TrackerRecordCoreData+CoreDataClass.swift
//  Tracker
//
//  Created by Alexey Kremnev on 3/5/25.
//
//

import Foundation
import CoreData

@objc(TrackerRecordCoreData)
class TrackerRecordCoreData: NSManagedObject {
    
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        return NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }
    
    @NSManaged public var date: Date
    @NSManaged public var tracker: TrackerCoreData
    
}
