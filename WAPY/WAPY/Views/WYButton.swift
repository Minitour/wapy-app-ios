//
//  WYButton.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 14/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class WYButton: UIButton {

    @IBInspectable
    open var styleAsInt: Int {
        get{
            return style.rawValue
        }set{
            style = Style(rawValue: newValue) ?? .normal
        }
    }

    open var style: Style = .normal {
        didSet{
            applyDesign()
        }
    }

    public convenience init(_ style: Style){
        self.init(frame: .zero)
        self.style = style
        applyDesign()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        applyDesign()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        applyDesign()
    }

    open func applyDesign(){
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        layer.shadowRadius = 3
        switch style {
        case .action:
            setTitleColor(.white, for: [])
            layer.backgroundColor = AppConfig.color.primary.cgColor
            layer.cornerRadius = bounds.height / 2.0
        case .normal:
            layer.backgroundColor = UIColor.white.cgColor
            layer.cornerRadius = 3
            setTitleColor(AppConfig.color.primary, for: [])
        }
    }

    override open var isHighlighted: Bool{
        set{
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.alpha = newValue ? 0.5 : 1
                self?.transform = newValue ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            }
            super.isHighlighted = newValue
        }get{
            return super.isHighlighted
        }
    }



    @objc
    public enum Style: Int {
        case normal
        case action
    }
}
