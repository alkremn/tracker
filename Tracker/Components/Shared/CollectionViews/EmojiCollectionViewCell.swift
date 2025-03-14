//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Alexey Kremnev on 3/2/25.
//

import UIKit

struct EmojiCollectionViewCellModel {
    let emoji: String
}

final class EmojiCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCollectionCell"
    
    private lazy var emojiLabel: UILabel = {
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
    
    func configure(with model: EmojiCollectionViewCellModel) {
        emojiLabel.text = model.emoji
    }
    
    func set(isActive: Bool) {
        backgroundColor = isActive ? UIColor(hex: "#E6E8EB") : .clear
    }
    
    private func configureUI() {
        addSubViews(emojiLabel)
        
        layer.cornerRadius = 8
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
