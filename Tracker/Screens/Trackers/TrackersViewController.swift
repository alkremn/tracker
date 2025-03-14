//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Alexey Kremnev on 1/31/25.
//

import UIKit

protocol TrackersViewControllerProtocol: AnyObject {
    func updateEmptyStateLabel(isHidden: Bool)
    func didUpdate(_ update: TrackerStoreUpdate)
    func reloadData()
}

final class TrackersViewController: UIViewController {
    
    private var presenter: TrackersPresenterProtocol
    
    private let cellsPerRow: CGFloat = 2
    private let cellSpacing: CGFloat = 9
    private let collectionInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    
    private lazy var filterDatePicker: UIDatePicker = {
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
            withReuseIdentifier: TrackersSectionHeaderView.reuseIdentifier
        )
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
    
    init(presenter: TrackersPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.viewDidLoad()
    }
    
    private func configureUI() {
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filterDatePicker)
        
        let searchVC = UISearchController()
        searchVC.searchBar.placeholder = "Поиск"
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        
        view.addSubViews(trackerCollectionView, emptyImageView, emptyLabel)
        
        NSLayoutConstraint.activate([
            trackerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
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
        
        trackerCollectionView.reloadData()
    }
    
    @objc private func addTrackerDidTap() {
        let navigationVC = UINavigationController()
        
        let createTrackerVC = TrackerTypeViewController(completion: { [weak self] in
            self?.dismiss(animated: true)
        })
        
        navigationVC.viewControllers = [ createTrackerVC ]
        present(navigationVC, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        presenter.filterDateChanged(date: sender.date)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackersSectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as? TrackersSectionHeaderView
        
        if let header {
            header.configure(with: presenter.title(for: indexPath.section))
            return header
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        collectionInsets
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let paddingWidth: CGFloat = collectionInsets.left + collectionInsets.right + (cellsPerRow - 1) * cellSpacing
        let cellWidth = (collectionView.frame.width - paddingWidth) / cellsPerRow
        return CGSize(width: cellWidth, height: 148)
    }
}

//MARK: - TrackersViewControllerProtocol

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func addTrackerButtonDidTap(for trackerId: UUID) {
        presenter.addTrackerButtonDidTap(for: trackerId)
    }
}

//MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        presenter.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.numberOfRowsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier,
            for: indexPath) as? TrackersCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.delegate = self
        cell.prepareForReuse()
        
        guard let trackerModel = presenter.tracker(at: indexPath) else { return UICollectionViewCell() }
        cell.configure(with: trackerModel)
        
        return cell
    }
}

//MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
    }
}

//MARK: - TrackersViewControllerProtocol

extension TrackersViewController: TrackersViewControllerProtocol {
    func updateEmptyStateLabel(isHidden: Bool){
        emptyImageView.isHidden = isHidden
        emptyLabel.isHidden = isHidden
    }
    
    func didUpdate(_ update: TrackerStoreUpdate) {
        trackerCollectionView.performBatchUpdates {
            trackerCollectionView.deleteItems(at: update.deletedRowsIndexes)
            trackerCollectionView.deleteSections(update.deletedSectionsIndexes)
            trackerCollectionView.insertSections(update.insertedSectionsIndexes)
            trackerCollectionView.insertItems(at: update.insertedRowsIndexes)
            trackerCollectionView.reloadItems(at: update.updatedRowsIndexes)
        }
    }
    
    func reloadData() {
        trackerCollectionView.reloadData()
    }
}
