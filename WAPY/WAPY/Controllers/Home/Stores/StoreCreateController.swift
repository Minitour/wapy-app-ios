//
//  StoreCreateController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 14/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit
import Eureka
import AZDialogView

public class StoreCreateController: FormViewController {

    lazy var imagePicker: SingleImageViewPicker = SingleImageViewPicker()

    lazy var dialog: AZDialogViewController = loadingDialog(title: "Creating Product")

    var selectedImage: UIImage?

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Store"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                            target: self,
                                                            action: #selector(didSelectCancel(_:)))

        form +++
        Section() { section in
            var header = HeaderFooterView<SingleImageViewPicker>(.callback {[unowned self] in return self.imagePicker})
            header.height = { 200.0 }
            // Will be called every time the header appears on screen
            header.onSetupView = { [weak self] view, _ in
                view.delegate = self
            }

            section.header = header
        }
        <<<
            NameRow(tag: "store_name").cellSetup { cell, row in
                row.placeholder = "Store Name"
        }
        <<<
            TextRow(tag: "store_address").cellSetup { cell, row in
                row.placeholder = "Address"
        }

        +++
        Section()
        <<<
            ButtonRow().cellSetup { cell,row in
                row.title = "Create"
        }
                .onCellSelection { [unowned self] cell, row in
                self.didSelectNext()
        }
    }

    @objc func didSelectCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    func didSelectNext() {

        dialog.show(in: self)

        guard let name = ( form.rowBy(tag: "store_name") as? NameRow )?.value, !name.isEmpty else {
            dialog.becomeErrorDialog(title: "Invalid name",
                                     message: "Please input a valid name for the store.")
            return
        }

        guard let image = self.selectedImage else {
            dialog.becomeErrorDialog(title: "Missing Image!",
                                     message: "Please attach an image to the store and try again.")
            return
        }

        dialog.title = "Uploading image..."
        API.shared.upload(image: image) { (url, err) in
            guard let urlStr = url?.absoluteString else {
                self.dialog.becomeErrorDialog(title: "Upload Failed",
                                              message: "Failed uploading the attached image. Please try again.")
                return
            }
            self.dialog.title = "Creating store..."
            self.createStore(url: urlStr)
        }
    }

    private func createStore(url: String) {

        guard let name = ( form.rowBy(tag: "store_name") as? NameRow )?.value else { return }

        guard let address = ( form.rowBy(tag: "store_address") as? TextRow )?.value else { return }
        

        API.shared.createStore(name: name, image: url, address: address) { (id, err) in

            if let id = id {
                // make delegate call?
                print(id)
                self.dismiss(animated: true, completion: nil)
            } else if let err = err {
                print(err)
            }
        }
    }

    
}

extension StoreCreateController: SingleImageViewPickerDelegate {
    public func singleImageViewPicker(_ imageViewPicker: SingleImageViewPicker,
                                      didRequestPresentationFor controller: UIViewController) {
        self.present(controller, animated: true, completion: nil)
    }

    public func singleImageViewPicker(_ imageViewPicker: SingleImageViewPicker, didSelectImage image: UIImage) {
        self.selectedImage = image
    }

}
