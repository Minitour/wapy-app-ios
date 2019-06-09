//
//  ProgressiveButton.swift
//  nbrs
//
//  Created by Antonio Zaitoun on 01/07/2018.
//  Copyright © 2018 Antonio Zaitoun. All rights reserved.
//

import UIKit

@IBDesignable
public class ProgressiveButton: UIButton {

    open var activityIndicatorViewStyle: UIActivityIndicatorView.Style {

        set{ activityIndicator.style = newValue }

        get { return activityIndicator.style }
    }

    open var status: Status = .next {
        didSet{
            refreshStatus()
        }
    }

    @IBInspectable
    open var nextTitle: String? = "Next"

    @IBInspectable
    open var skipTitle: String? = "Skip"

    @IBInspectable
    open var errorTitle: String? = "Error"

    @IBInspectable
    open var color: UIColor = COLOR_ACCENT{
        didSet {
            refreshStatus()
        }
    }

    @IBInspectable
    open var colorDarker: UIColor?

    @IBInspectable
    open var isRounded: Bool = false

    @IBInspectable
    open var animateInteraction: Bool = false

    fileprivate lazy var activityIndicator: UIActivityIndicatorView = .init()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func refreshStatus() {
        activityIndicator.isHidden = status != .progress
        backgroundColor = status == .skip ? .clear : color
        isUserInteractionEnabled = true

        switch status {
        case .next:
            setTitle(nextTitle, for: [])
        case .skip:
            setTitle(skipTitle, for: [])
        case .error:
            setTitle(errorTitle, for: [])
        case .progress:
            activityIndicator.startAnimating()
            setTitle(nil, for: [])
            isUserInteractionEnabled = false
        case .disabled:
            setTitle(nextTitle, for: [])
            backgroundColor = color.darker()
            isUserInteractionEnabled = false
        }
    }

    fileprivate func setup() {
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityIndicator.hidesWhenStopped = false
        activityIndicator.style = .whiteLarge
        setTitleColor(.white, for: [])
        tintColor = .white
    }

    public enum Status {
        case next
        case skip
        case progress
        case error
        case disabled
    }

    public override func prepareForInterfaceBuilder() {
        status = .progress
    }

    override public var isHighlighted: Bool{
        set{
            backgroundColor = newValue ? (colorDarker ?? color.darker()) : color
            if animateInteraction {
                UIView.animate(withDuration: 0.1) { [weak self] in
                    self?.alpha = newValue ? 0.5 : 1
                    self?.transform = newValue ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
                }
            }
            super.isHighlighted = newValue
        }get{
            return super.isHighlighted
        }
    }


    public func show(in time: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {[weak self] in
            self?.isHidden = false
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        if isRounded {
            layer.cornerRadius = self.bounds.height / 2.0
            layer.masksToBounds = true
        }
    }
}
