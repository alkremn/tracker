//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/11/25.
//

import UIKit

protocol CollectionViewCellDelegate: AnyObject {
    func addTrackerButtonDidTap(for trackerId: UUID)
}

final class CollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "CollectionCell"
    
    weak var delegate: TrackersCollectionViewCellDelegate?
    
    private var isChecked = false
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.backgroundColor = .init(hex: "#ffffff", alpha: 0.3)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, daysCount: Int) {
        
    }
    
    private func configureUI() {
//        addSubViews(headerView, durationLabel, addButton)
        
        NSLayoutConstraint.activate([
       
        ])
    }
}
