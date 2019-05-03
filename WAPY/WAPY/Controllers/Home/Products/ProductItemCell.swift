//
//  ProductItemCell.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 03/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit

public class ProductItemCell: UITableViewCell {

    var productImage: UIImageView!
    var productNameLabel: UILabel!

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {

        productImage = UIImageView()
        productNameLabel = UILabel()

        productImage.translatesAutoresizingMaskIntoConstraints = false
        productNameLabel.translatesAutoresizingMaskIntoConstraints = false

        let v = contentView

        v.addSubview(productImage)
        NSLayoutConstraint.activate([
            productImage.topAnchor.constraint(equalTo: v.topAnchor),
            productImage.bottomAnchor.constraint(equalTo: v.bottomAnchor),
            productImage.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            productImage.trailingAnchor.constraint(equalTo: v.trailingAnchor)
        ])

        v.addSubview(productNameLabel)
        NSLayoutConstraint.activate([
            productNameLabel.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            productNameLabel.trailingAnchor.constraint(equalTo: v.trailingAnchor),
            productNameLabel.bottomAnchor.constraint(equalTo: v.bottomAnchor),
            productNameLabel.heightAnchor.constraint(equalToConstant: 60.0)
        ])

        // apply styles

        productImage.contentMode = .scaleAspectFit
        productImage.layer.masksToBounds = true

        productNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        productNameLabel.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0.6954439029)
        productNameLabel.textColor = .white
    }

    public override func prepareForReuse() {
        productImage.image = nil
        productNameLabel.text = nil
    }
}
