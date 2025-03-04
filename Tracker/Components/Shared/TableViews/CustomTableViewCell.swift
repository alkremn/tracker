//
//  CustomTableViewCell.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/20/25.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
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
    
    let separator = UIView()
    
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
    
    func configure(title: String, subtitle: String?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        if let subtitle, !subtitle.isEmpty {
            titleCenterYConstraint?.isActive = false
            titleTopConstraint?.isActive = true
        } else {
            titleCenterYConstraint?.isActive = true
            titleTopConstraint?.isActive = false
        }
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
