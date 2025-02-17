//
//  CreateEventViewController.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/10/25.
//

import UIKit

final class CreateEventViewController: UIViewController {
    
    private let titleLabel = UILabel(text: "Новое нерегулярное событие")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    private func configureUI() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = .systemBackground
        view.addSubViews(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}
