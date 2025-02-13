//
//  CreateHabitViewController.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/10/25.
//

import UIKit

class CreateHabitViewController: UIViewController {
    
    private let headerTitle: UILabel = {
        let title = UILabel()
        title.text = "Новая привычка"
        return title
    }()
    
    private let titleField: UITextField = {
        let textField = TTextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .tLightGray
        textField.layer.cornerRadius = 16
        return textField
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.layer.borderColor = UIColor.tRed.cgColor
        button.layer.borderWidth = 1
        button.setTitleColor(.tRed, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.backgroundColor = UIColor.systemBackground.cgColor
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.layer.backgroundColor = UIColor.tGray.cgColor
        button.layer.cornerRadius = 16
        return button
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            cancelButton,
            createButton
        ])
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    private func configureUI() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = .systemBackground
        view.addSubViews(headerTitle, titleField, buttonsStack)
        
        NSLayoutConstraint.activate([
            headerTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            headerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleField.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: 24),
            titleField.heightAnchor.constraint(equalToConstant: 75),
            
            buttonsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
