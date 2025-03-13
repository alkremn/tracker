//
//  CreateHabitViewController.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/10/25.
//

import UIKit

final class CreateTrackerViewController: UIViewController {
    
    enum TrackerType {
        case habit, event
    }
    
    enum Options {
        case category, schedule
    }
    
    private let titleLabel = UILabel(text: "", weight: .medium)
    
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
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var colorsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        return collectionView
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
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var contentContainer: UIView = {
        let container = UIView()
        container.addSubViews(
            titleField,
            optionsTableView,
            emojiCollectionView,
            colorsCollectionView
        )
        return container
    }()
    
    private var options: [Options] = [ .category ]
    
    private let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    private let colors: [String] = [
        "#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4",
        "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC",
        "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"
    ]
    
    private let trackerType: TrackerType

    private let collectionInsets: UIEdgeInsets = UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
    private let cellsPerRow: CGFloat = 6
    private let cellSpacing: CGFloat = 5
    
    private var trackerStore = TrackerStore()
    private var selectedCategory: TrackerCategory?
    private var activeDays: [WeekDay] = []
    private var selectedEmoji: String?
    private var selectedColor: String?
    private let completion: () -> Void
    
    init(trackerType: TrackerType, completion: @escaping () -> Void) {
        try? print(FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false))
        
        self.completion = completion
        self.trackerType = trackerType
        
        titleLabel.text = self.trackerType == .habit ? "Новая привычка" : "Новое нерегулярное событие"
        if self.trackerType == .habit {
            options.append(.schedule)
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        createDismissKeyboardTapGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = contentContainer.frame.size
    }
    
    private func configureUI() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = .systemBackground
        
        view.addSubViews(titleLabel, scrollView, buttonsStack)
        scrollView.addSubViews(contentContainer)
    
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -84),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            contentContainer.bottomAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 20),
            
            titleField.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            titleField.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            titleField.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            titleField.heightAnchor.constraint(equalToConstant: 75),
            
            optionsTableView.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 24),
            optionsTableView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            optionsTableView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            optionsTableView.heightAnchor.constraint(equalToConstant: trackerType == .habit ? 150 : 80),

            emojiCollectionView.topAnchor.constraint(equalTo: optionsTableView.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 228),
            
            colorsCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 32),
            colorsCollectionView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            colorsCollectionView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 228),
            
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func titleFieldDidChange() {
        createButton.set(isEnabled: isFormValid)
    }
    
    @objc private func cancelButtonDidTap() {
        completion()
    }
    
    @objc private func createButtonDidTap() {
        guard let title = titleField.text,
              let selectedCategory, let selectedColor, let selectedEmoji else
        { return }
        
        let tracker = Tracker(
            id: UUID(),
            name: title,
            hexColor: selectedColor,
            icon: selectedEmoji,
            schedule: trackerType == .habit ? activeDays : nil
        )
        do {
            try trackerStore.add(tracker: tracker, categoryId: selectedCategory.id)
            completion()
        } catch {
            print("Unable to create tracker with error: \(error.localizedDescription)")
        }
        completion()
    }
    
    private var isFormValid: Bool {
        if let title = titleField.text {
            let isValid = !title.isEmpty && selectedCategory != nil && selectedEmoji != nil && selectedColor != nil
            return trackerType == .habit ? isValid && !activeDays.isEmpty : isValid
        }
        return false
    }
}

//MARK: - UITableViewDataSource

extension CreateTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CustomTableViewCell.identifier,
                for: indexPath) as? CustomTableViewCell
        else { return UITableViewCell() }
        
        let option = options[indexPath.row]
        switch option {
        case .category:
            cell.configure(with: createCustomTableViewCellModel(
                title: "Категория",
                subtitle: selectedCategory?.title,
                isSeparatorHidden: indexPath.row == 0))
        case .schedule:
            cell.configure(with: createCustomTableViewCellModel(
                title: "Расписание",
                subtitle: activeDays.map{ $0.shortName }.joined(separator: ", "),
                isSeparatorHidden: indexPath.row == 0))
        }
      
        return cell
    }
    
    private func createCustomTableViewCellModel(
        title: String,
        subtitle: String?,
        isSeparatorHidden: Bool
    ) -> CustomTableViewCellModel
    {
        CustomTableViewCellModel(
            title: title,
            subtitle: subtitle,
            isSeparatorHidden: isSeparatorHidden,
            accessoryType: .disclosureIndicator)
    }
}

//MARK: - UITableViewDelegate

extension CreateTrackerViewController: UITableViewDelegate {
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

//MARK: - TrackerCategoryViewControllerDelegate

extension CreateTrackerViewController: TrackerCategoryViewControllerDelegate {
    func didSelect(category: TrackerCategory?) {
        selectedCategory = category
        createButton.set(isEnabled: isFormValid)
        optionsTableView.reloadData()
    }
}

//MARK: - TrackerScheduleViewControllerDelegate

extension CreateTrackerViewController: TrackerScheduleViewControllerDelegate {
    func didSelect(_ activeDays: [WeekDay]) {
        self.activeDays = activeDays
        createButton.set(isEnabled: isFormValid)
        optionsTableView.reloadData()
    }
}

//MARK: - UICollectionViewDataSource

extension CreateTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == emojiCollectionView ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView,
           let emojiCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier,
            for: indexPath) as? EmojiCollectionViewCell
        {
            emojiCell.prepareForReuse()
            emojiCell.configure(with: .init(emoji: emojis[indexPath.row]))
           
            return emojiCell
        } else {
            guard let colorCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier,
                for: indexPath) as? ColorCollectionViewCell else { return UICollectionViewCell() }
            colorCell.prepareForReuse()
            let color = colors[indexPath.row]
            colorCell.configure(with: .init(color: UIColor(hex: color) ?? .clear, isSelected: color == selectedColor))
            
            return colorCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView,
           let emojiCell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell {
            selectedEmoji = emojis[indexPath.row]
            emojiCell.set(isActive: true)
        } else {
            guard let colorCell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            else { return }
            
            selectedColor = colors[indexPath.row]
            colorCell.set(isActive: true)
        }
        createButton.set(isEnabled: isFormValid)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView,
           let emojiCell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell {
            emojiCell.set(isActive: false)
        } else {
            guard let colorCell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            else { return }
            colorCell.set(isActive: false)
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as? SectionHeaderView
        
        if let header {
            header.configure(with: .init(title: collectionView == emojiCollectionView ? "Emoji" : "Цвет"))
            return header
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingWidth: CGFloat = collectionInsets.left + collectionInsets.right + (cellsPerRow - 1) * cellSpacing
        let cellWidth = (collectionView.frame.width - paddingWidth) / cellsPerRow
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        collectionInsets
    }
}
