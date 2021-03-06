//
//  ProductSelectionController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 03/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit

public protocol ProductSelectionControllerDelegate: class {

    /// called when the product is selected
    func didSelectProduct(_ controller: ProductSelectionController, product: Product)

    /// called when cancel is selected
    func didCancelSelection(_ controller: ProductSelectionController)
}

public class ProductSelectionController: ProductsViewController{

    open weak var delegate: ProductSelectionControllerDelegate?

    public override func viewDidLoad() {
        super.viewDidLoad()


        self.remoteDelegate.didSelectItem = { [unowned self] product in
            self.delegate?.didSelectProduct(self, product: product)
        }
        
        navigationItem.rightBarButtonItem
            = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didSelectCancel(_:)))
    }

    @objc func didSelectCancel(_ sender: UIBarButtonItem) {
        delegate?.didCancelSelection(self)
    }


}
