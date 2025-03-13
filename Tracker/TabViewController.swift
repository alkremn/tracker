//
//  ViewController.swift
//  Tracker
//
//  Created by Alexey Kremnev on 1/29/25.
//

import UIKit

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersPresenter = TrackersPresenter()
        let trackersVC = TrackersViewController(presenter: trackersPresenter)
        trackersPresenter.view = trackersVC
        
        let navVC = UINavigationController()
        navVC.viewControllers = [trackersVC]
        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(systemName: "record.circle.fill"), tag: 0)

        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(systemName: "hare.fill"), tag: 1)
        
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.5))
        lineView.backgroundColor = UIColor(hex: "#000000", alpha: 0.3)
        tabBar.addSubview(lineView)
        
        viewControllers = [navVC, statisticsVC]
    }
}
