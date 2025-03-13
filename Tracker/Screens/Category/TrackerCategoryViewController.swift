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
    private let titleLabel = UILabel(text: "Категория", weight: .medium)
    private lazy var categoryStore = TrackerCategoryStore(delegate: self)
     
    private lazy var categoriesTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
        tableView.separatorStyle = .none
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoriesTableView.reloadData()
    }
    
    private func configureUI() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = .systemBackground
        
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
        categoryStore.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as? CustomTableViewCell
        else { return UITableViewCell() }
        
        cell.prepareForReuse()
        
        let categoryId = categoryStore.trackerCategories[indexPath.row].id
        
        let cellModel = CustomTableViewCellModel(
            title: categoryStore.trackerCategories[indexPath.row].title,
            subtitle: nil,
            backgroundColor: .inputBackground,
            isSeparatorHidden: indexPath.row == 0,
            accessoryType: selectedCategory?.id == categoryId ? .checkmark : .none
        )
        
        cell.configure(with: cellModel)
        
        if indexPath.row == categoryStore.trackerCategories.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.cornerRadius = 0
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate

extension TrackerCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categoryStore.trackerCategories[indexPath.row]
        delegate?.didSelect(category: category)
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - CreateCategoryViewControllerDelegate

extension TrackerCategoryViewController: CreateCategoryViewControllerDelegate {
    func categoryNameDidSelect(name: String) {
        let newCategory = TrackerCategory(id: UUID(), title: name, trackers: [])
        do {
            try categoryStore.addNewTrackerCategory(category: newCategory)
        } catch {
            print(error)
        }
    }
}

extension TrackerCategoryViewController: TrackerCategoryStoreDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        categoriesTableView.performBatchUpdates {
            let insertPaths = update.insertedIndexes.map({ IndexPath(item: $0, section: 0) })
            categoriesTableView.insertRows(at: insertPaths, with: .automatic)
        }
    }
}
