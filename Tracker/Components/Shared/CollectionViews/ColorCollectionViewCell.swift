//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Alexey Kremnev on 3/4/25.
//

import UIKit

struct ColorCollectionViewCellModel {
    let color: UIColor
}

final class ColorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCollectionCell"
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private var color: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: ColorCollectionViewCellModel) {
        color = model.color
        colorView.backgroundColor = model.color
        layer.borderColor = UIColor.clear.cgColor
    }
    
    func set(isActive: Bool) {
        layer.borderColor = isActive ? color?.withAlphaComponent(0.3).cgColor : UIColor.clear.cgColor
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
