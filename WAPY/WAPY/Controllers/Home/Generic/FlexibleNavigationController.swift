//
//  FlexiableNavigationController.swift
//  nbrs
//
//  Created by Antonio Zaitoun on 14/07/2018.
//  Copyright © 2018 Antonio Zaitoun. All rights reserved.
//

import UIKit

public class FlexibleNavigationController: UINavigationController {

    var autorotate: Bool = true

    var statusBarStyle: UIStatusBarStyle = .default {
        didSet{
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    var statusBarHidden: Bool = false {
        didSet{
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    public override var shouldAutorotate: Bool {
        return autorotate
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    public override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }

}

extension UINavigationController {

    func clearStack(removeAllExcept controller: UIViewController) {
        setViewControllers([controller], animated: true)
    }
}

extension UIViewController {
    var flexibleNav: FlexibleNavigationController? {
        return self.navigationController as? FlexibleNavigationController
    }
}
