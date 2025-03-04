//
//  SupplementaryView.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/12/25.
//

import UIKit

final class SectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "SectionHeaderView"
    
    private let titleLabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 19, weight: .bold)
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    private func configureUI() {
        addSubViews(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
