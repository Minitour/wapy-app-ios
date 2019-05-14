//
//  StorePickerController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 11/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit

public protocol StoreSelectionControllerDelegate: class {

    /// called when the product is selected
    func didSelectStore(_ controller: StoreSelectionController, store: Store)

    /// called when cancel is selected
    func didCancelSelection(_ controller: StoreSelectionController)
}

public class StoreSelectionController: StoresViewController{

    open weak var delegate: StoreSelectionControllerDelegate?

    public override func viewDidLoad() {
        super.viewDidLoad()


        self.remoteDelegate.didSelectItem = { [unowned self] store in
            self.delegate?.didSelectStore(self, store: store)
        }

        navigationItem.rightBarButtonItem
            = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didSelectCancel(_:)))
    }

    @objc func didSelectCancel(_ sender: UIBarButtonItem) {
        delegate?.didCancelSelection(self)
    }


}
