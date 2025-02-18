//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Alexey Kremnev on 1/31/25.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private var categories: [TrackerCategory] = MockData.categories
    private var completedTrackers: [TrackerRecord] = []
    private var completedTrackerIds: Set<UUID> = Set()
    private var currentDate: Date = Date() {
        didSet {
            filterCategories(by: currentDate)
            trackerCollectionView.reloadData()
        }
    }
    private let cellsPerRow: CGFloat = 2
    private let cellSpacing: CGFloat = 9
    private let collectionInserts: UIEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var trackerCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier)
        collectionView.register(
            TrackersSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackersSectionHeaderView.reuseIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private var emptyImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .star))
        return imageView
    }()
    
    private var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func configureUI() {
        title = "Трекеры"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTrackerDidTap)
        )
        
        navigationItem.leftBarButtonItem?.tintColor = .tBlack
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        let searchVC = UISearchController()
        searchVC.searchBar.placeholder = "Поиск"
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        
        view.addSubViews(trackerCollectionView, emptyImageView, emptyLabel)
        emptyImageView.isHidden = true
        emptyLabel.isHidden = true
        
        
        NSLayoutConstraint.activate([
            trackerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor)
        ])
        
        filterCategories(by: currentDate)
        trackerCollectionView.reloadData()
    }
    
    private func filterCategories(by date: Date) {
        var weekdayInt = Calendar.current.component(.weekday, from: date)
        weekdayInt = weekdayInt == 1 ? 7 : weekdayInt - 1
        
        guard let weekday = WeekDay(rawValue: weekdayInt) else { return }
        
        categories = MockData.categories.compactMap { category in
            let filterTrackers = category.trackers.filter {$0.schedule.contains(weekday) }
            return filterTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filterTrackers)
        }
        updateCollectionViewEmptyState()
    }
    
    private func updateCollectionViewEmptyState() {
        if categories.isEmpty {
            emptyImageView.isHidden = false
            emptyLabel.isHidden = false
        } else {
            emptyImageView.isHidden = true
            emptyLabel.isHidden = true
        }
    }
    
    @objc private func addTrackerDidTap() {
        let navigationVC = UINavigationController()
        let createTrackerVC = TrackerTypeViewController()
        createTrackerVC.delegate = self
        navigationVC.viewControllers = [ createTrackerVC ]
        
        present(navigationVC, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
    }
}

//MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier,
            for: indexPath) as? TrackersCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.delegate = self
        cell.prepareForReuse()
        
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        let isCompleted = completedTrackers.contains {
            $0.id == tracker.id && Calendar.current.isDate($0.date, equalTo: currentDate, toGranularity: .day) }
        
        let daysCount = completedTrackers.count { $0.id == tracker.id }
        cell.configure(with: tracker, isCompleted: isCompleted, daysCount: daysCount)
        
        return cell
    }
}


//MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackersSectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as! TrackersSectionHeaderView
        
        header.configure(with: categories[indexPath.section].title)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        collectionInserts
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let paddingWidth: CGFloat = collectionInserts.left + collectionInserts.right + (cellsPerRow - 1) * cellSpacing
        let cellWidth = (collectionView.frame.width - paddingWidth) / cellsPerRow
        return CGSize(width: cellWidth, height: 148)
    }
}

//MARK: - TrackersViewControllerProtocol

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func addTrackerButtonDidTap(for trackerId: UUID) {
        let calendar = Calendar.current
        
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) else { return }
        let startOfDay = calendar.startOfDay(for: tomorrow)
        
        if currentDate >= startOfDay { return }
        
        if completedTrackerIds.contains(trackerId),
           let foundIdx = completedTrackers.firstIndex(where: { $0.id == trackerId
               && Calendar.current.isDate($0.date, equalTo: currentDate, toGranularity: .day) })
        {
            completedTrackers.remove(at: foundIdx)
            completedTrackerIds.remove(trackerId)
        } else {
            completedTrackers.append(.init(id: trackerId, date: currentDate))
            completedTrackerIds.insert(trackerId)
        }
        
        trackerCollectionView.reloadData()
    }
}

//MARK: - TrackerTypeViewControllerDelegate

extension TrackersViewController: TrackerTypeViewControllerDelegate {
    func createHabitButtonDidTap(category: TrackerCategory, tracker: Tracker) {
        var trackers = category.trackers
        trackers.append(tracker)
        
        let newCategory = TrackerCategory(title: category.title, trackers: trackers)
        
        if let categoryIdx = MockData.categories.firstIndex(where: { $0.id == category.id }) {
            MockData.categories[categoryIdx] = newCategory
        } else {
            MockData.categories.append(newCategory)
        }
        
        filterCategories(by: currentDate)
        trackerCollectionView.reloadData()
    }
}

//MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
    }
}
