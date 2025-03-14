//
//  TrackerStore.swift
//  Tracker
//
//  Created by Alexey Kremnev on 3/1/25.
//

import UIKit
import CoreData

struct TrackerStoreUpdate {
    let insertedSectionsIndexes: IndexSet
    let deletedSectionsIndexes: IndexSet
    let insertedRowsIndexes: [IndexPath]
    let deletedRowsIndexes: [IndexPath]
    let updatedRowsIndexes: [IndexPath]
}

protocol TrackerStoreProtocol {
    var trackers: [Tracker] { get }
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    
    private var insertedSectionsIndexes: IndexSet?
    private var deletedSectionsIndexes: IndexSet?
    private var insertedRowsIndexes: [IndexPath]?
    private var deletedRowsIndexes: [IndexPath]?
    private var updatedRowsIndexes: [IndexPath]?
    
    private weak var delegate: TrackerStoreDelegate?
    
    private lazy var fetchResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.createFetchRequest()
        fetchRequest.sortDescriptors = [
            .init(key: #keyPath(TrackerCoreData.category.title), ascending: true)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    var trackers: [Tracker] {
        self.fetchResultsController.fetchedObjects?.map { self.tracker(from: $0) } ?? []
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    convenience init(delegate: TrackerStoreDelegate? = nil) {
        self.init(context: CoreDataStack.shared.viewContext)
        self.delegate = delegate
    }
    
    func fetchTrackers(on weekDay: Int, date: Date) {
        fetchResultsController.fetchRequest.predicate =
            .init(format: "(%K == nil AND (%K.@count == 0 OR SUBQUERY(%K, $r, $r.date == %@).@count > 0))"
                  + "OR (%K != nil AND %K CONTAINS %@)",
                  #keyPath(TrackerCoreData.schedule),
                  #keyPath(TrackerCoreData.records),
                  #keyPath(TrackerCoreData.records),
                  date as CVarArg,
                  #keyPath(TrackerCoreData.schedule),
                  #keyPath(TrackerCoreData.schedule),
                  "\(weekDay)")
        
        try? fetchResultsController.performFetch()
    }
    
    func add(tracker: Tracker, categoryId: UUID) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.hexColor = tracker.hexColor
        trackerCoreData.icon = tracker.icon
        trackerCoreData.schedule = tracker.schedule?.string
        
        let category = TrackerCategoryStore(context: context).getCategory(by: categoryId)
        category?.addToTrackers(trackerCoreData)
        
        try context.save()
    }
    
    func getTracker(by id: UUID) -> TrackerCoreData? {
        fetchResultsController.fetchedObjects?.first { $0.id == id }
    }
    
    func numberOfSections() -> Int {
        fetchResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func title(for section: Int) -> String {
        fetchResultsController.sections?[section].name ?? ""
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker {
        let model = fetchResultsController.object(at: indexPath)
        return tracker(from: model)
    }
    
    func isCompleted(at indexPath: IndexPath, on date: Date) -> Bool {
        let records = fetchResultsController.object(at: indexPath).records as? Set<TrackerRecordCoreData>
        return records?.contains { Calendar.current.isDate($0.date, equalTo: date, toGranularity: .day) } ?? false
    }
    
    func count(at indexPath: IndexPath) -> Int {
        return fetchResultsController.object(at: indexPath).records?.count ?? 0
    }
    
    private func tracker(from trackerCoreData: TrackerCoreData) -> Tracker {
        return Tracker(
            id: trackerCoreData.id,
            name: trackerCoreData.name,
            hexColor: trackerCoreData.hexColor,
            icon: trackerCoreData.icon,
            schedule: trackerCoreData.schedule?.toWeekDayArray()
        )
    }
}

//MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedSectionsIndexes = IndexSet()
        deletedSectionsIndexes = IndexSet()
        insertedRowsIndexes = []
        deletedRowsIndexes = []
        updatedRowsIndexes = []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        if let insertedSectionsIndexes, let deletedSectionsIndexes,
           let insertedRowsIndexes, let deletedRowsIndexes, let updatedRowsIndexes {
            delegate?.didUpdate(
                .init(
                    insertedSectionsIndexes: insertedSectionsIndexes,
                    deletedSectionsIndexes: deletedSectionsIndexes,
                    insertedRowsIndexes: insertedRowsIndexes,
                    deletedRowsIndexes: deletedRowsIndexes,
                    updatedRowsIndexes: updatedRowsIndexes
                )
            )
        }
        
        insertedSectionsIndexes = nil
        deletedSectionsIndexes = nil
        insertedRowsIndexes = nil
        deletedRowsIndexes = nil
        updatedRowsIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>,
                    didChange sectionInfo: any NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSectionsIndexes?.insert(sectionIndex)
        case .delete:
            deletedSectionsIndexes?.insert(sectionIndex)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedRowsIndexes?.append(indexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedRowsIndexes?.append(indexPath)
            }
        case .update:
            if let indexPath = indexPath {
                updatedRowsIndexes?.append(indexPath)
            }
        default:
            break
        }
    }
}
