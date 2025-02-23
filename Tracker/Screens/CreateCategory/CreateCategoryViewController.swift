//
//  CreateTrackerCategoryViewController.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/15/25.
//

import UIKit

protocol CreateCategoryViewControllerDelegate: AnyObject {
    func categoryNameDidSelect(name: String)
}

final class CreateCategoryViewController: UIViewController {
    
    weak var delegate: CreateCategoryViewControllerDelegate?
    
    private let titleLabel = UILabel(text: "Новая категория", weight: .medium)
    
    private lazy var categoryField: UITextField = {
        let textField = TTextField()
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = .tLightGray
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(categoryFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var finishButton = TButton(
        title: "Готово",
        target: self,
        action: #selector(finishButtonDidTap),
        isEnabled: false
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        createDismissKeyboardTapGesture()
    }
    
    private func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func finishButtonDidTap() {
        if let name = categoryField.text {
            delegate?.categoryNameDidSelect(name: name)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func categoryFieldDidChange(_ sender: UITextField) {
        if let name = sender.text {
            finishButton.set(isEnabled: !name.isEmpty)
        }
    }
    
    private func configureUI() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = .systemBackground
        view.addSubViews(titleLabel, categoryField, finishButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            categoryField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            categoryField.heightAnchor.constraint(equalToConstant: 75),
            
            finishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            finishButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
