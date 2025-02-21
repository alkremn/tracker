//
//  TrackerScheduleViewController.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/15/25.
//

import UIKit

protocol TrackerScheduleViewControllerDelegate: AnyObject {
    func didSelect(_ activeWeekDays: [WeekDay])
}

final class TrackerScheduleViewController: UIViewController {
    
    weak var delegate: TrackerScheduleViewControllerDelegate?
    
    private var activeDays: [WeekDay]
    private let titleLabel = UILabel(text: "Расписание", weight: .medium)
    
    private lazy var selectedDaysTableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var finishButton = TButton(
        title: "Готово",
        target: self,
        action: #selector(finishButtonDidTap))
    
    init(activeDays: [WeekDay]) {
        self.activeDays = activeDays
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
        view.addSubViews(titleLabel, selectedDaysTableView, finishButton)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            finishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            finishButton.heightAnchor.constraint(equalToConstant: 60),
            
            selectedDaysTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            selectedDaysTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selectedDaysTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            selectedDaysTableView.heightAnchor.constraint(equalToConstant: 525)
        ])
    }
    
    @objc private func finishButtonDidTap() {
        delegate?.didSelect(activeDays)
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - UITableViewDataSource

extension TrackerScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weekdayInt = indexPath.row + 1
        guard let weekday = WeekDay(rawValue: weekdayInt) else { return UITableViewCell()}
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.backgroundColor = .inputBackground
        cell.textLabel?.text = weekday.fullName
        cell.accessoryView = createToggleSwitch(tag: weekdayInt, isActive: activeDays.contains(weekday))
        
        if indexPath.row < WeekDay.allCases.count - 1 {
            let line = UIView(frame: CGRect(x: 20, y: cell.bounds.height + 31, width: cell.bounds.width, height: 1))
            line.backgroundColor = UIColor(hex: "#AEAFB4", alpha: 0.6)
            cell.addSubview(line)
        }
        
        return cell
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        guard let weekday = WeekDay(rawValue: sender.tag) else { return }
        if activeDays.contains(weekday) {
            activeDays = activeDays.filter({ $0 != weekday })
        } else {
            activeDays.append(weekday)
            activeDays.sort()
        }
    }
    
    private func createToggleSwitch(tag: Int, isActive: Bool) -> UISwitch {
        let toggleSwitch = UISwitch()
        toggleSwitch.tag = tag
        toggleSwitch.onTintColor = .init(hex: "#3772E7")
        toggleSwitch.setOn(isActive, animated: false)
        toggleSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        return toggleSwitch
    }
}

extension TrackerScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

