//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Alexey Kremnev on 3/4/25.
//

import UIKit
import CoreData

struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

final class TrackerCategoryStore: NSObject {
    
    private let context: NSManagedObjectContext
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    private weak var delegate: TrackerCategoryStoreDelegate?
    
    private lazy var fetchResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.createFetchRequest()
        fetchRequest.sortDescriptors = [
            .init(key: "title", ascending: true)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    var trackerCategories: [TrackerCategory] {
        guard let objects = self.fetchResultsController.fetchedObjects else { return [] }
        
        let trackerCategories = objects.map({ self.trackerCategory(from: $0) })
        return trackerCategories
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init(delegate: TrackerCategoryStoreDelegate? = nil) {
        self.init(context: CoreDataStack.shared.newBackgroundContext())
        self.delegate = delegate
    }
    
    func addNewTrackerCategory(category: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.id = category.id
        trackerCategoryCoreData.title = category.title
        trackerCategoryCoreData.trackers = []
        
        try context.save()
    }
    
    func getCategory(by id: UUID) -> TrackerCategoryCoreData? {
        fetchResultsController.fetchedObjects?.first { $0.id == id }
    }
    
    func object(at indexPath: IndexPath) -> TrackerCategoryCoreData? {
        fetchResultsController.object(at: indexPath)
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    private func trackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) -> TrackerCategory {
        return TrackerCategory(
            id: trackerCategoryCoreData.id,
            title: trackerCategoryCoreData.title,
            trackers: []
        )
    }
}

//MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        if let insertedIndexes, let deletedIndexes {
            delegate?.didUpdate(.init(insertedIndexes: insertedIndexes, deletedIndexes: deletedIndexes))
        }
        
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}
