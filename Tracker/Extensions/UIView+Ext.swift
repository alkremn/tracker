//
//  UIView+Ext.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/9/25.
//

import UIKit


extension UIView {
    func addSubViews(_ views: UIView...) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }
}
