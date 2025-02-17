//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/9/25.
//

import UIKit

protocol TrackerTypeViewControllerDelegate: AnyObject {
    func createHabitButtonDidTap(category: TrackerCategory, tracker: Tracker)
}

final class TrackerTypeViewController: UIViewController {
    
    weak var delegate: TrackerTypeViewControllerDelegate?
    
    private let titleLabel = UILabel(text: "Создание трекера")
    private lazy var habitButton = TButton(
        title: "Привычка",
        target: self,
        action: #selector(habitButtonDidTap))
    
    private lazy var eventButton = TButton(
        title: "Нерегулярные событие",
        target: self,
        action: #selector(eventButtonDidTap))
    
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
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubViews(titleLabel, stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc private func habitButtonDidTap() {
        let createHabitVC = CreateHabitViewController()
        createHabitVC.delegate = self
        navigationController?.pushViewController(createHabitVC, animated: true)
    }
    
    @objc private func eventButtonDidTap() {
    }
}

//MARK: - CreateHabitViewControllerDelegate

extension TrackerTypeViewController: CreateHabitViewControllerDelegate {
    func createHabitButtonDidTap(category: TrackerCategory, tracker: Tracker) {
        delegate?.createHabitButtonDidTap(category: category, tracker: tracker)
    }
}
