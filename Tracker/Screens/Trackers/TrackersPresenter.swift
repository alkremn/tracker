//
//  TrackersPresenter.swift
//  Tracker
//
//  Created by Alexey Kremnev on 3/5/25.
//

import Foundation

protocol TrackersPresenterProtocol: AnyObject {
    var view: TrackersViewControllerProtocol? { get set }
    func viewDidLoad()
    func filterDateChanged(date: Date)
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func title(for section: Int) -> String
    func tracker(at indexPath: IndexPath) -> TrackersCollectionViewCellModel?
    func addTrackerButtonDidTap(for trackerId: UUID)
    func addTracker(tracker: Tracker, categoryId: UUID)
}

final class TrackersPresenter: TrackersPresenterProtocol {
    
    var view: TrackersViewControllerProtocol?
    
    private lazy var trackerStore = TrackerStore(delegate: self)
    private let trackerRecordStore = TrackerRecordStore()
   
    private var filterDate: Date = Date()
    private var completedTrackers: [TrackerRecord] = []
        
    func viewDidLoad() {
        fetchTrackersBy(date: Date().localDate)
        view?.updateEmptyStateLabel(isHidden: !trackerStore.trackers.isEmpty)
    }
    
    func filterDateChanged(date: Date) {
        filterDate = date.localDate
        fetchTrackersBy(date: filterDate)
        view?.reloadData()
        view?.updateEmptyStateLabel(isHidden: !trackerStore.trackers.isEmpty)
    }
    
    func numberOfSections() -> Int {
        trackerStore.numberOfSections()
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        trackerStore.numberOfRowsInSection(section)
    }
    
    func title(for section: Int) -> String {
        trackerStore.title(for: section)
    }
    
    func tracker(at indexPath: IndexPath) -> TrackersCollectionViewCellModel? {
        let tracker = trackerStore.tracker(at: indexPath)
        
        let startOfDay = Calendar.current.startOfDay(for: filterDate)
        let isCompleted = trackerStore.isCompleted(at: indexPath, on: startOfDay)
        let daysCount = trackerStore.count(at: indexPath)
        
        return TrackersCollectionViewCellModel(
            trackerId: tracker.id,
            icon: tracker.icon,
            name: tracker.name,
            hexColor: tracker.hexColor,
            isCompleted: isCompleted,
            daysCount: daysCount
        )
    }
    
    func addTrackerButtonDidTap(for trackerId: UUID) {
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date().localDate) else { return }
        let tomorrowStartOfDay = Calendar.current.startOfDay(for: tomorrow)
        
        if filterDate >= tomorrowStartOfDay { return }
        
        let startOfDay = Calendar.current.startOfDay(for: filterDate)
        guard let tracker = trackerStore.getTracker(by: trackerId) else {
            print("Failed to find tracker")
            return
        }
      
        do {
            try trackerRecordStore.add(model: .init(trackerId: trackerId, date: startOfDay), tracker: tracker)
        } catch {
            print("Failed to save tracker record with error \(error.localizedDescription)")
        }
    }
    
    private func fetchTrackersBy(date: Date) {
        var weekday = Calendar.current.component(.weekday, from: date)
        weekday = weekday == 1 ? 7 : weekday - 1
        let startOfDay = Calendar.current.startOfDay(for: filterDate)
        trackerStore.fetchTrackers(on: weekday, date: startOfDay)
    }
    
    func addTracker(tracker: Tracker, categoryId: UUID) {
        do {
            try trackerStore.add(tracker: tracker, categoryId: categoryId)
        } catch {
            print("Failed to save tracker with error \(error.localizedDescription)")
        }
    }
}

//MARK: - TrackerStoreDelegate

extension TrackersPresenter: TrackerStoreDelegate  {
    func didUpdate(_ update: TrackerStoreUpdate) {
        view?.didUpdate(update)
        view?.updateEmptyStateLabel(isHidden: !trackerStore.trackers.isEmpty)
    }
}
