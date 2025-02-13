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
        
        let trackersVC = TrackersViewController()
        let navVC = UINavigationController()
        navVC.viewControllers = [trackersVC]
        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(systemName: "record.circle.fill"), tag: 0)

        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(systemName: "hare.fill"), tag: 1)
        
        viewControllers = [navVC, statisticsVC]
    }
}

