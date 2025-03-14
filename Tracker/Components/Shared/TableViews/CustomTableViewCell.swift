//
//  CustomTableViewCell.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/20/25.
//

import UIKit

struct CustomTableViewCellModel {
    let title: String
    let subtitle: String?
    let backgroundColor: UIColor
    let isSeparatorHidden: Bool
    let accessoryType: UITableViewCell.AccessoryType
    let selectionStyle: UITableViewCell.SelectionStyle
    
    init(
        title: String,
        subtitle: String?,
        backgroundColor: UIColor = .inputBackground,
        isSeparatorHidden: Bool,
        accessoryType: UITableViewCell.AccessoryType = .none,
        selectionStyle: UITableViewCell.SelectionStyle = .none
    ) {
        self.title = title
        self.subtitle = subtitle
        self.backgroundColor = backgroundColor
        self.isSeparatorHidden = isSeparatorHidden
        self.accessoryType = accessoryType
        self.selectionStyle = selectionStyle
    }
}

final class CustomTableViewCell: UITableViewCell {
    static let identifier = "CustomCell"
    
    private lazy var titleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private lazy var subtitleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .init(hex: "#AEAFB4")
        return label
    }()
    
    private var titleCenterYConstraint: NSLayoutConstraint?
    private var titleTopConstraint: NSLayoutConstraint?
    private let separator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
        separator.backgroundColor = UIColor(hex: "#AEAFB4", alpha: 0.6)
        contentView.addSubview(separator)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        separator.frame = CGRect(x: 16, y: 0, width: bounds.width - 32, height: 1)
    }
    
    func configure(with model: CustomTableViewCellModel) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        
        if let subtitle = model.subtitle, !subtitle.isEmpty {
            titleCenterYConstraint?.isActive = false
            titleTopConstraint?.isActive = true
        } else {
            titleCenterYConstraint?.isActive = true
            titleTopConstraint?.isActive = false
        }
        
        backgroundColor = model.backgroundColor
        accessoryType = model.accessoryType
        selectionStyle = model.selectionStyle
        
        separator.isHidden = model.isSeparatorHidden
    }
    
    private func configureUI() {
        contentView.addSubViews(titleLabel, subtitleLabel)
        
        let titleCenterYConstraint = titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        let titleTopConstraint = titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15)
        self.titleCenterYConstraint = titleCenterYConstraint
        self.titleTopConstraint = titleTopConstraint
        
        NSLayoutConstraint.activate([
            titleCenterYConstraint,
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)
        ])
    }
}
