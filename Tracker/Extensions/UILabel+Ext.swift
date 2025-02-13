//
//  UILabel.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/12/25.
//

import UIKit


extension UILabel {
    func setTextWithLineHeight(_ text: String?, lineHeight: CGFloat) {
        guard let text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.alignment = self.textAlignment
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        
        self.attributedText = attributedString
    }
}
