//
//  CreateHabitViewController.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/10/25.
//

import UIKit

protocol CreateTrackerViewControllerProtocol: AnyObject {
    func updateCreateButtonState(isEnabled: Bool)
    func reloadData()
}

final class CreateTrackerViewController: UIViewController {
    
    private var presenter: CreateTrackerPresenterProtocol
    private let trackerType: TrackerType
    
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
    
    private let collectionInsets: UIEdgeInsets = UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
    private let cellsPerRow: CGFloat = 6
    private let cellSpacing: CGFloat = 5
    
    init(presenter: CreateTrackerPresenterProtocol, trackerType: TrackerType) {
        self.presenter = presenter
        self.trackerType = trackerType
        titleLabel.text = self.trackerType == .habit ? "Новая привычка" : "Новое нерегулярное событие"
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
        presenter.titleFieldDidChange(titleText: titleField.text ?? "")
    }
    
    @objc private func cancelButtonDidTap() {
        presenter.cancelButtonDidTap()
    }
    
    @objc private func createButtonDidTap() {
        presenter.createButtonDidTap()
    }
}

//MARK: - UITableViewDataSource

extension CreateTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as? CustomTableViewCell
        else { return UITableViewCell() }
        
        let cellModel = presenter.cellModel(at: indexPath)
        cell.configure(with: cellModel)
        return cell
    }
}

//MARK: - UITableViewDelegate

extension CreateTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let viewController = presenter.didSelectRowAt(at:indexPath)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

//MARK: - UICollectionViewDataSource

extension CreateTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        presenter.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == emojiCollectionView ? presenter.emojis.count : presenter.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView,
           let emojiCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier,
            for: indexPath) as? EmojiCollectionViewCell
        {
            emojiCell.prepareForReuse()
            emojiCell.configure(with: .init(emoji: presenter.emojis[indexPath.row]))
           
            return emojiCell
        } else {
            guard let colorCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier,
                for: indexPath) as? ColorCollectionViewCell else { return UICollectionViewCell() }
            colorCell.prepareForReuse()
            let color = presenter.colors[indexPath.row]
            colorCell.configure(with: .init(color: UIColor(hex: color) ?? .clear))
            
            return colorCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView,
           let emojiCell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell {
            presenter.didSelectItemAt(at: indexPath, isEmoji: true)
            emojiCell.set(isActive: true)
        } else {
            guard let colorCell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            else { return }
            presenter.didSelectItemAt(at: indexPath, isEmoji: false)
            colorCell.set(isActive: true)
        }
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

//MARK: - CreateTrackerViewControllerProtocol

extension CreateTrackerViewController: CreateTrackerViewControllerProtocol {    
    func updateCreateButtonState(isEnabled: Bool) {
        createButton.set(isEnabled: isEnabled)
    }
    
    func reloadData() {
        optionsTableView.reloadData()
    }
}
