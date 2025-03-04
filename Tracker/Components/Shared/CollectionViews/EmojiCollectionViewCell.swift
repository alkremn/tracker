//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Alexey Kremnev on 3/2/25.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCollectionCell"
    
    lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
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
    
    private func configureUI() {
        addSubViews(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
