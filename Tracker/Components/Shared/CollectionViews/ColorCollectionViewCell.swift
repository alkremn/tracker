//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Alexey Kremnev on 3/4/25.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCollectionCell"
    
    lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        addSubViews(colorView)
        layer.cornerRadius = 8
        layer.borderWidth = 3
        
        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            colorView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            colorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
    }
}
