//
//  TrackerRecordCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Alexey Kremnev on 3/5/25.
//
//

import Foundation
import CoreData


extension TrackerRecordCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        return NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }



}

extension TrackerRecordCoreData : Identifiable {

}
