//
//  CreateTrackerPresenter.swift
//  Tracker
//
//  Created by Alexey Kremnev on 3/13/25.
//

import UIKit

protocol CreateTrackerPresenterProtocol {
    var options: [Options] { get }
    var emojis: [String] { get }
    var colors: [String] { get }
    var isFormValid: Bool { get }
    func cancelButtonDidTap()
    func titleFieldDidChange(titleText: String)
    func createButtonDidTap()
    func numberOfSections() -> Int
    func didSelectRowAt(at indexPath: IndexPath) -> UIViewController
    func cellModel(at indexPath: IndexPath) -> CustomTableViewCellModel
    func didSelectItemAt(at indexPath: IndexPath, isEmoji: Bool)
}

enum TrackerType {
    case habit, event
}

enum Options {
    case category, schedule
}

final class CreateTrackerPresenter: CreateTrackerPresenterProtocol {

    weak var view: CreateTrackerViewControllerProtocol?

    var options: [Options] = [ .category ]
    
    let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    let colors: [String] = [
        "#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4",
        "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC",
        "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"
    ]
    
    private let trackerType: TrackerType
    private var trackerStore = TrackerStore()
    
    private var titleText: String = ""
    private var selectedCategory: TrackerCategory?
    private var activeDays: [WeekDay] = []
    private var selectedEmoji: String?
    private var selectedColor: String?
    private let completion: () -> Void
    
    var isFormValid: Bool {
        let isValid = !titleText.isEmpty && selectedCategory != nil && selectedEmoji != nil && selectedColor != nil
        return trackerType == .habit ? isValid && !activeDays.isEmpty : isValid
    }
    
    init(trackerType: TrackerType, completion: @escaping () -> Void) {
        self.trackerType = trackerType
        self.completion = completion
    
        if self.trackerType == .habit {
            options.append(.schedule)
        }
    }
    
    func cancelButtonDidTap() {
        completion()
    }
    
    func titleFieldDidChange(titleText: String) {
        self.titleText = titleText
        view?.updateCreateButtonState(isEnabled: isFormValid)
    }
    
    func createButtonDidTap() {
        guard !titleText.isEmpty, let selectedCategory, let selectedColor, let selectedEmoji else { return }
        
        let tracker = Tracker(
            id: UUID(),
            name: titleText,
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

    func numberOfSections() -> Int {
        1
    }
    
    func didSelectRowAt(at indexPath: IndexPath) -> UIViewController {
        let selectedOption = options[indexPath.row]
        switch selectedOption {
        case .category:
            let categoryVC = TrackerCategoryViewController(selectedCategory: selectedCategory)
            categoryVC.delegate = self
            return categoryVC
        case .schedule:
            let scheduleVC = TrackerScheduleViewController(activeDays: activeDays)
            scheduleVC.delegate = self
            return scheduleVC
        }
    }
    
    func didSelectItemAt(at indexPath: IndexPath, isEmoji: Bool) {
        if isEmoji {
            selectedEmoji = emojis[indexPath.row]
        } else {
            selectedColor = colors[indexPath.row]
        }
        view?.updateCreateButtonState(isEnabled: isFormValid)
    }
    
    func cellModel(at indexPath: IndexPath) -> CustomTableViewCellModel {
        let option = options[indexPath.row]
        switch option {
        case .category:
            return createCustomTableViewCellModel(
                title: "Категория",
                subtitle: selectedCategory?.title,
                isSeparatorHidden: indexPath.row == 0)
        case .schedule:
            return createCustomTableViewCellModel(
                title: "Расписание",
                subtitle: activeDays.map{ $0.shortName }.joined(separator: ", "),
                isSeparatorHidden: indexPath.row == 0)
        }
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

//MARK: - TrackerCategoryViewControllerDelegate

extension CreateTrackerPresenter: TrackerCategoryViewControllerDelegate {
    func didSelect(category: TrackerCategory?) {
            selectedCategory = category
            view?.updateCreateButtonState(isEnabled: isFormValid)
            view?.reloadData()
    }
}

//MARK: - TrackerScheduleViewControllerDelegate

extension CreateTrackerPresenter: TrackerScheduleViewControllerDelegate {
    func didSelect(_ activeWeekDays: [WeekDay]) {
        self.activeDays = activeWeekDays
        view?.updateCreateButtonState(isEnabled: isFormValid)
        view?.reloadData()
    }
}
