//
//  SystemButton.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 06/04/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit

extension UIButton{

    class func systemButton(withTitle title: String = "Button") -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = COLOR_ACCENT
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.tintColor = .white
        button.setTitle(title, for: [])
        return button
    }
}
