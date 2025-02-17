//
//  SelectTrackerCategoryViewController.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/15/25.
//

import UIKit

protocol TrackerCategoryViewControllerDelegate: AnyObject {
    func didSelect(category: TrackerCategory?)
}

final class TrackerCategoryViewController: UIViewController {
    
    weak var delegate: TrackerCategoryViewControllerDelegate?
    
    private var selectedCategory: TrackerCategory?
    private let titleLabel = UILabel(text: "Категория")
    
    private lazy var categoriesTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.cornerRadius = 16
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var addCategoryButton = TButton(
        title: "Добавить категорию",
        target: self,
        action: #selector(addCategoryButtonDidTap)
    )
    
    private var categories = MockData.categories
    
    init(selectedCategory: TrackerCategory?) {
        self.selectedCategory = selectedCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    private func configureUI() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = .systemBackground
        categoriesTableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        view.addSubViews(titleLabel, categoriesTableView, addCategoryButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            categoriesTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -10)
        ])
    }
    
    @objc private func addCategoryButtonDidTap() {
        let createCategoryVC = CreateCategoryViewController()
        createCategoryVC.delegate = self
        navigationController?.pushViewController(createCategoryVC, animated: true)
    }
}

//MARK: - UITableViewDataSource

extension TrackerCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .inputBackground
        cell.textLabel?.text = categories[indexPath.row].title
        cell.clipsToBounds = true
        cell.accessoryType = selectedCategory?.id == categories[indexPath.row].id ? .checkmark : .none
        
        if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        if indexPath.row == categories.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        cell.selectionStyle = .none
        return cell
    }
}

//MARK: - UITableViewDelegate

extension TrackerCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        delegate?.didSelect(category: category)
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - CreateCategoryViewControllerDelegate

extension TrackerCategoryViewController: CreateCategoryViewControllerDelegate {
    func categoryNameDidSelect(name: String) {
        let newCategory = TrackerCategory(title: name, trackers: [])
        MockData.categories.append(newCategory)
        categories = MockData.categories
        categoriesTableView.reloadData()
    }
}

