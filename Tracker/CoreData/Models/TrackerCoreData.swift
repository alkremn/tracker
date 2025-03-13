//
//  TrackerCoreData+CoreDataClass.swift
//  Tracker
//
//  Created by Alexey Kremnev on 3/5/25.
//
//

import Foundation
import CoreData

@objc(TrackerCoreData)
public class TrackerCoreData: NSManagedObject {
    
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var icon: String
    @NSManaged public var name: String
    @NSManaged public var hexColor: String
    @NSManaged public var schedule: String?
    @NSManaged public var category: TrackerCategoryCoreData
    @NSManaged public var records: NSSet?
}

// MARK: Generated accessors for records
extension TrackerCoreData {

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: TrackerRecordCoreData)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: TrackerRecordCoreData)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)

}
