//
//  TrackerCategoryCoreData+CoreDataClass.swift
//  Tracker
//
//  Created by Alexey Kremnev on 3/5/25.
//
//

import Foundation
import CoreData

@objc(TrackerCategoryCoreData)
public class TrackerCategoryCoreData: NSManagedObject {
    
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<TrackerCategoryCoreData> {
        return NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var trackers: NSSet?
}

// MARK: Generated accessors for trackers
extension TrackerCategoryCoreData {

    @objc(addTrackersObject:)
    @NSManaged public func addToTrackers(_ value: TrackerCoreData)

    @objc(removeTrackersObject:)
    @NSManaged public func removeFromTrackers(_ value: TrackerCoreData)

    @objc(addTrackers:)
    @NSManaged public func addToTrackers(_ values: NSSet)

    @objc(removeTrackers:)
    @NSManaged public func removeFromTrackers(_ values: NSSet)

}
