//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Alexey Kremnev on 1/31/25.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private var completedTrackers: [TrackerRecord] = []
    private let cellsPerRow: CGFloat = 2
    private let cellSpacing: CGFloat = 9
    private let collectionInserts: UIEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    
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
        let imageView = UIImageView(image: UIImage(resource: ._1))
        return imageView
    }()
    
    private var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12)
        return label
    }()

    private var categories: [TrackerCategory] = [
        .init(title: "Домашний уют", trackers: [
            .init(name: "Поливать растения", color: "#33CF69", icon: "❤️", schedule: "1 день"),
        ]),
        .init(title: "Радостные мелочи", trackers: [
            .init(name: "Кошка заслонила камеру на созвоне", color: "#FF881E", icon: "😻", schedule: "5 дней"),
            .init(name: "Бабушка прислала открытку в вотсапе", color: "#FD4C49", icon: "🌺", schedule: "4 дня")
        ])
    ]
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func configureUI() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTrackerDidTap)
        )
        
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
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
        
        trackerCollectionView.reloadData()
    }
    
    @objc func addTrackerDidTap() {
        let navigationVC = UINavigationController()
        navigationVC.viewControllers = [
            SelectTrackerTypeViewController()
        ]
        
        present(navigationVC, animated: true)
    }
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        
        cell.prepareForReuse()
        cell.configure(with: categories[indexPath.section].trackers[indexPath.row])
        return cell
    }
}

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

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
    }
}
