//
//  TButton.swift
//  Tracker
//
//  Created by Alexey Kremnev on 2/9/25.
//

import UIKit

class TButton: UIButton {
    
    private let buttonBackgroundColor: UIColor

    override init(frame: CGRect) {
        buttonBackgroundColor = .tBlack
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(
        title: String,
        target:Any?,
        action: Selector,
        isEnabled: Bool = true,
        backgroundColor: UIColor = .tBlack
    ) {
        self.buttonBackgroundColor = backgroundColor
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.addTarget(target, action: action, for: .touchUpInside)
        self.backgroundColor = backgroundColor
        self.alpha = isEnabled ? 1.0 : 0.5
        self.isEnabled = isEnabled
        
        configureUI()
    }
    
    func set(isEnabled: Bool) {
        self.isEnabled = isEnabled
        self.alpha = isEnabled ? 1.0 : 0.5
    }
    
    private func configureUI() {
        layer.cornerRadius = 16
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
    }
}
