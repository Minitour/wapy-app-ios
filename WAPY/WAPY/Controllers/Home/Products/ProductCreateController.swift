//
//  ProductCreateController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 14/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit
import Eureka
import AZDialogView

public class ProductCreateController: FormViewController {

    lazy var imagePicker: SingleImageViewPicker = SingleImageViewPicker()

    var selectedImage: UIImage?

    lazy var dialog: AZDialogViewController = loadingDialog(title: "Creating Product")

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Product"
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
            NameRow(tag: "product_name").cellSetup { cell, row in
                row.placeholder = "Product Name"
            }
            <<<
            TextAreaRow(tag: "product_description").cellSetup { cell, row in
                row.placeholder = "Description"
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

        guard let name = ( form.rowBy(tag: "product_name") as? NameRow )?.value, !name.isEmpty else {
            dialog.becomeErrorDialog(title: "Invalid name",
                                     message: "Please input a valid name for the product.")
            return
        }

        guard let image = self.selectedImage else {
            dialog.becomeErrorDialog(title: "Missing Image!",
                                     message: "Please attach an image to the product and try again.")
            return
        }

        dialog.title = "Uploading image..."
        API.shared.upload(image: image) { (url, err) in
            guard let urlStr = url?.absoluteString else {
                self.dialog.becomeErrorDialog(title: "Upload Failed",
                                         message: "Failed uploading the attached image. Please try again.")
                return
            }
            self.dialog.title = "Creating product..."
            self.createProduct(url: urlStr)
        }
    }

    private func createProduct(url: String) {

        guard let name = ( form.rowBy(tag: "product_name") as? NameRow )?.value else {
            print("name not provided")
            return
        }

        let description = ( form.rowBy(tag: "product_description") as? TextAreaRow )?.value

        API.shared.createProduct(name: name, image: url, description: description ?? "") { (id, err) in

            if let id = id {
                // make delegate call?
                print(id)
                self.dialog.dismiss(animated: true) {
                    self.dismiss(animated: true, completion: nil)
                }
            } else if let err = err {
                self.dialog.becomeErrorDialog(title: "Error", message: err.localizedDescription)
            }
        }
    }


}

extension ProductCreateController: SingleImageViewPickerDelegate {
    public func singleImageViewPicker(_ imageViewPicker: SingleImageViewPicker,
                                      didRequestPresentationFor controller: UIViewController) {
        self.present(controller, animated: true, completion: nil)
    }

    public func singleImageViewPicker(_ imageViewPicker: SingleImageViewPicker, didSelectImage image: UIImage) {
        self.selectedImage = image
    }

}

