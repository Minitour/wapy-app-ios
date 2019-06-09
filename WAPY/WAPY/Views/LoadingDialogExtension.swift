//
//  LoadingDialogExtension.swift
//  nbrs
//
//  Created by Antonio Zaitoun on 28/10/2018.
//  Copyright © 2018 Antonio Zaitoun. All rights reserved.
//

import AZDialogView

var GLOBAL_STYLE: (UIButton,CGFloat,Int)->Void = { btn,height,indx in
    btn.layer.masksToBounds = false
    btn.layer.shadowColor = UIColor.darkGray.cgColor
    btn.layer.shadowOpacity = 0.3
    btn.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    btn.layer.shadowRadius = 4
    btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
}

var GLOBAL_BUTTON_INIT: (Int) -> UIButton? = {_ in
    let claimButton = ProgressiveButton()
    claimButton.status = .next
    claimButton.isRounded = true
    claimButton.animateInteraction = true
    claimButton.color = COLOR_ACCENT


    return claimButton
}

func loadingDialog(title: String) -> AZDialogViewController {

    let dialog = AZDialogViewController(title: title)
    dialog.blurBackground = false
    dialog.allowDragGesture = false
    dialog.dismissWithOutsideTouch = false
    dialog.customViewSizeRatio = 0.2
    dialog.buttonInit = GLOBAL_BUTTON_INIT
    dialog.buttonStyle = GLOBAL_STYLE

    let container = dialog.container
    let indicator = UIActivityIndicatorView(style: .gray)

    dialog.container.addSubview(indicator)
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
    indicator.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
    indicator.startAnimating()

    return dialog
}

extension AZDialogViewController {

    func becomeLoadingDialog(title: String? = "Loading",
                             message: String? = nil) {
        self.title = title
        self.message = message
        for v in container.subviews { v.removeFromSuperview() }

        removeAllActions()

        cancelEnabled = false

        allowDragGesture = false
        dismissWithOutsideTouch = false
        customViewSizeRatio = 0.2

        let indicator = UIActivityIndicatorView(style: .gray)

        container.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        indicator.startAnimating()

        contentOffset = 0.0
    }

    func becomeSuccessDialog(title: String? = "Success",
                             message: String? = nil,
                             doneMessage: String = "Done",
                             doneAction: ((AZDialogViewController)->Void)? = { _ in }){
        self.title = title
        self.message = message
        dismissWithOutsideTouch = true
        rubberEnabled = true
        customViewSizeRatio = 0.0
        removeAllActions()

        let done = AZDialogAction(title: doneMessage,handler: doneAction)
        addAction(done)
    }

    func becomeErrorDialog(title: String? = "Error",
                           message: String? = nil,
                           tryAgainMessage: String = "Try Again",
                           cancelMessage: String = "Cancel",
                           tryAgainClosure: (()-> Void)? = nil,
                           cancelClosure: (()->Void)? = {}) {
        self.title = title
        self.message = message
        dismissWithOutsideTouch = true
        rubberEnabled = true
        customViewSizeRatio = 0.0
        removeAllActions()

        if let tryAgainClosure = tryAgainClosure {
            let tryAgainAction = AZDialogAction(title: tryAgainMessage) { (dialog) -> (Void) in
                dialog.dismiss(animated: true) {
                    tryAgainClosure()
                }
            }
            addAction(tryAgainAction)
        }
        if let cancelClosure = cancelClosure {
            let cancel = AZDialogAction(title: cancelMessage) { (dialog) -> (Void) in
                dialog.dismiss(animated: true) {
                    cancelClosure()
                }
            }
            addAction(cancel)
        }
    }

    func bringAbove(_ height: CGFloat) {
        self.contentOffset = (self.view.bounds.height / 2.0 - self.estimatedHeight / 2.0) - height
    }
}
