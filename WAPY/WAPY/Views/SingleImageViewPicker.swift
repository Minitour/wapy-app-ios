//
//  SingleImageViewPicker.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 14/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit

fileprivate class ActionButton: WYButton {
    override func applyDesign() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        layer.shadowRadius = 3
        setTitleColor(.darkGray, for: [])
        tintColor = .darkGray
        layer.backgroundColor = UIColor.white.cgColor
        layer.cornerRadius = bounds.height / 2.0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyDesign()
    }
}

public protocol SingleImageViewPickerDelegate: class {

    /// Called when controller requests to present a picker controller.
    ///
    /// - Parameters:
    ///   - imageViewPicker: The image picker view.
    ///   - controller: The controller to present.
    func singleImageViewPicker(_ imageViewPicker: SingleImageViewPicker, didRequestPresentationFor controller: UIViewController)

    func singleImageViewPicker(_ imageViewPicker: SingleImageViewPicker, didSelectImage image: UIImage)

    func didRemoveImage(_ imageViewPicker: SingleImageViewPicker)
}

public extension SingleImageViewPickerDelegate {
    func singleImageViewPicker(_ imageViewPicker: SingleImageViewPicker, didRequestPresentationFor controller: UIViewController) {}
    func singleImageViewPicker(_ imageViewPicker: SingleImageViewPicker, didSelectImage image: UIImage) {}
    func didRemoveImage(_ imageViewPicker: SingleImageViewPicker) {}
}

open class SingleImageViewPicker: UIView {

    /// The primary image view
    var imageView: UIImageView!

    /// add image button
    var addImageButton: UIButton!

    /// remove image button
    var clearButton: UIButton!

    open weak var delegate: SingleImageViewPickerDelegate?

    var hasImage: Bool = false {
        didSet{
            self.clearButton.isHidden = !self.hasImage
            self.addImageButton.isHidden = self.hasImage
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        imageView = UIImageView()
        addImageButton = ActionButton(.normal)
        clearButton = ActionButton(.normal)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        // setup image view as the background
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])

        let stackView = UIStackView(arrangedSubviews: [addImageButton,clearButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8.0
        stackView.distribution = .fillEqually
        addSubview(stackView)

        // constraint the stackview to the bottom left
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 8.0),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -8.0),
            stackView.widthAnchor.constraint(equalToConstant: 50.0),
            stackView.heightAnchor.constraint(equalToConstant: 50.0)
            ])

        // apply styles
        addImageButton.setImage(#imageLiteral(resourceName: "ic_image"), for: [])
        clearButton.setImage(#imageLiteral(resourceName: "ic_close"), for: [])

        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = #imageLiteral(resourceName: "image_placeholder")

        // add actions
        addImageButton.addTarget(self, action: #selector(addImage(_:)), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(removeData(_:)), for: .touchUpInside)

        hasImage = false

    }

    @objc func addImage(_ sender: UIButton) {
        if let delegate = delegate {
            let picker = UIImagePickerController()
            picker.delegate = self
            delegate.singleImageViewPicker(self, didRequestPresentationFor: picker)
        }
    }

    @objc func removeData(_ sender: UIButton) {
        self.imageView.image = #imageLiteral(resourceName: "image_placeholder")
        delegate?.didRemoveImage(self)
        hasImage = false
    }
}

extension SingleImageViewPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = pickedImage
            delegate?.singleImageViewPicker(self, didSelectImage: pickedImage)
            hasImage = true
        }

        picker.dismiss(animated: true, completion: nil)
    }
}
