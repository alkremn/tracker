//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/9/25.
//

import UIKit

final class SelectTrackerTypeViewController: UIViewController {
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let habitButton = TButton(title: "Привычка")
    private let eventButton = TButton(title: "Нерегулярные событие")
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            habitButton,
            eventButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        habitButton.addTarget(self, action: #selector(habitButtonDidTap), for: .touchUpInside)
        eventButton.addTarget(self, action: #selector(eventButtonDidTap), for: .touchUpInside)
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubViews(label, stackView)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc private func habitButtonDidTap() {
        navigationController?.pushViewController(CreateHabitViewController(), animated: true)
    }
    
    @objc private func eventButtonDidTap() {
        navigationController?.pushViewController(CreateEventViewController(), animated: true)
    }
}
