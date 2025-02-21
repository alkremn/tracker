//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/11/25.
//

import UIKit

protocol TrackersCollectionViewCellDelegate: AnyObject {
    func addTrackerButtonDidTap(for trackerId: UUID)
}

final class TrackersCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackersCollectionCell"
    
    weak var delegate: TrackersCollectionViewCellDelegate?
    
    private var trackerId: UUID?
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
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.addSubViews(emojiLabel, titleLabel)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.tintColor = .white
        button.addTarget(self, action: #selector(addButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, daysCount: Int) {
        self.trackerId = tracker.id
        emojiLabel.text = tracker.icon
        titleLabel.text = tracker.name
        titleLabel.setTextWithLineHeight(tracker.name, lineHeight: 18)
        durationLabel.text = getDurationText(daysCount: daysCount)
        headerView.backgroundColor = .init(hex: tracker.color)
        addButton.backgroundColor =  isCompleted ? .init(hex: tracker.color, alpha: 0.5) : .init(hex: tracker.color)
        let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        addButton.setImage(UIImage(systemName: isCompleted ? "checkmark" : "plus", withConfiguration: config), for: .normal)
    }
    
    private func configureUI() {
        addSubViews(headerView, durationLabel, addButton)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12),
            
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -12),
            
            durationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            durationLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            
            addButton.heightAnchor.constraint(equalToConstant: 34),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            addButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func addButtonDidTap() {
        guard let trackerId else { return }
        delegate?.addTrackerButtonDidTap(for: trackerId)
    }
    
    private func getDurationText(daysCount: Int) -> String {
        switch daysCount {
        case 1:
            return "\(daysCount) день"
        case 2...3:
            return "\(daysCount) дня"
        default:
            return "\(daysCount) дней"
        }
    }
}
