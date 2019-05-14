//
//  StoreCell.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 12/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit
import Eureka
import Foundation

public final class StoreRow: OptionsRow<PushSelectorCell<Store>>, PresenterRowType, RowType {

    public typealias PresenterRow = StorePickerViewControllerSub

    /// Defines how the view controller will be presented, pushed, etc.
    public var presentationMode: PresentationMode<PresenterRow>?

    /// Will be called before the presentation occurs.
    public var onPresentCallback: ((FormViewController, PresenterRow) -> Void)?



    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback {
            let controller = StorePickerViewControllerSub()
            return controller
        }, onDismiss: { vc in _ = vc.navigationController?.popViewController(animated: true) })

        displayValueFor = {
            guard let store = $0 else { return "" }
            return  store.name
        }
    }

    /**
     Extends `didSelect` method
     */
    public override func customDidSelect() {
        super.customDidSelect()
        guard let presentationMode = presentationMode, !isDisabled else { return }
        if let controller = presentationMode.makeController() {
            controller.row = self
            controller.title = selectorTitle ?? controller.title
            onPresentCallback?(cell.formViewController()!, controller)
            presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
        } else {
            presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
        }
    }

    /**
     Prepares the pushed row setting its title and completion callback.
     */
    public override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        guard let rowVC = segue.destination as? PresenterRow else { return }
        rowVC.title = selectorTitle ?? rowVC.title
        rowVC.onDismissCallback = presentationMode?.onDismissCallback ?? rowVC.onDismissCallback
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
    }
}

public class StorePickerViewControllerSub: StoreSelectionController, TypedRowControllerType, StoreSelectionControllerDelegate {

    public func didSelectStore(_ controller: StoreSelectionController, store: Store) {
        self.row.value = store
        self.onDismissCallback?(self)
    }

    public func didCancelSelection(_ controller: StoreSelectionController) {
        self.onDismissCallback?(self)
    }

    public typealias RowValue = Store
    public var row: RowOf<Store>!

    public var onDismissCallback: ((UIViewController) -> Void)?

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup(){
        self.delegate = self
    }
}
