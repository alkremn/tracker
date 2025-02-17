//
//  CreateHabitViewController.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/10/25.
//

import UIKit

protocol CreateHabitViewControllerDelegate: AnyObject {
    func createHabitButtonDidTap(category: TrackerCategory, tracker: Tracker)
}

final class CreateHabitViewController: UIViewController {
    
    enum Options {
        case category, schedule
    }
    
    weak var delegate: CreateHabitViewControllerDelegate?
    
    private let titleLabel = UILabel(text: "Новая привычка")
    
    private lazy var titleField: UITextField = {
        let textField = TTextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .tLightGray
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(titleFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var optionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.layer.borderColor = UIColor.tRed.cgColor
        button.layer.borderWidth = 1
        button.setTitleColor(.tRed, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.backgroundColor = UIColor.systemBackground.cgColor
        button.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton = TButton(
        title: "Создать",
        target: self,
        action: #selector(createButtonDidTap),
        isEnabled: false
    )
    
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            cancelButton,
            createButton
        ])
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let options: [Options] = [
        .category,
        .schedule
    ]
    
    private var selectedCategory: TrackerCategory?
    private var activeDays: [WeekDay] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        createDismissKeyboardTapGesture()
    }
    
    private func configureUI() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = .systemBackground
        view.addSubViews(titleLabel, titleField, optionsTableView, buttonsStack)
        
        optionsTableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            titleField.heightAnchor.constraint(equalToConstant: 75),
            
            optionsTableView.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 24),
            optionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            optionsTableView.heightAnchor.constraint(equalToConstant: 150),
            
            buttonsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func titleFieldDidChange() {
        createButton.set(isEnabled: isFormValid())
    }
    
    @objc private func cancelButtonDidTap() {
        dismiss(animated: true)
    }

    @objc private func createButtonDidTap() {
        guard
            let title = titleField.text,
            let selectedCategory else
        { return }
        
        let newTracker = Tracker(name: title, color: "", icon: "", schedule: activeDays)
        delegate?.createHabitButtonDidTap(category: selectedCategory, tracker: newTracker)
        dismiss(animated: true)
    }
    
    private func isFormValid() -> Bool {
        if let title = titleField.text {
            return !title.isEmpty && selectedCategory != nil && !activeDays.isEmpty
        }
        return false
    }
}

extension CreateHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.backgroundColor = .inputBackground
        cell.detailTextLabel?.textColor = .tGray

        let option = options[indexPath.row]
        switch option {
        case .category:
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = selectedCategory?.title
        case .schedule:
            cell.textLabel?.text = "Расписание"
            cell.detailTextLabel?.text = activeDays.map{ $0.shortName }.joined(separator: ", ")
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension CreateHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let selectedOption = options[indexPath.row]
        
        switch selectedOption {
        case .category:
            let categoryVC = TrackerCategoryViewController(selectedCategory: selectedCategory)
            categoryVC.delegate = self
            navigationController?.pushViewController(categoryVC, animated: true)
        case .schedule:
            let scheduleVC = TrackerScheduleViewController(activeDays: activeDays)
            scheduleVC.delegate = self
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

extension CreateHabitViewController: TrackerCategoryViewControllerDelegate {
    func didSelect(category: TrackerCategory?) {
        selectedCategory = category
        createButton.set(isEnabled: isFormValid())
        optionsTableView.reloadData()
    }
}

extension CreateHabitViewController: TrackerScheduleViewControllerDelegate {
    func didSelect(_ activeDays: [WeekDay]) {
        self.activeDays = activeDays
        createButton.set(isEnabled: isFormValid())
        optionsTableView.reloadData()
    }
}
