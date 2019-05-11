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
    var productDateLabel: UILabel!

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {

        selectionStyle = .none

        let cardView = CardView()
        productImage = UIImageView()
        productNameLabel = UILabel()
        productDateLabel = UILabel()

        productImage.contentMode = .scaleAspectFill
        productImage.layer.masksToBounds = true

        productNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        productDateLabel.font = UIFont.systemFont(ofSize: 13)

        productDateLabel.textColor = .gray

        cardView.cornerRadius = 15.0
        cardView.layer.masksToBounds = true
        cardView.backgroundColor = .white

        // layout store image view
        cardView.addSubview(productImage)
        productImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            productImage.topAnchor.constraint(equalTo: cardView.topAnchor),
            productImage.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            productImage.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            productImage.heightAnchor.constraint(equalTo: cardView.heightAnchor,multiplier: 0.7)
            ])

        // layout store name label

        let stackView = UIStackView(arrangedSubviews: [productNameLabel,productDateLabel])
        stackView.axis = .vertical

        cardView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: productImage.bottomAnchor,constant: 8.0),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor,constant: 13.0),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor,constant: -8.0),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor,constant: -8.0)
            ])

        // layout card view
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 8.0),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 8.0),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -8.0)
            ])

        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowRadius = 5.0
        contentView.layer.shadowOffset = CGSize(width: 1, height: 1)
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.masksToBounds = false
    }

    public override func prepareForReuse() {
        productImage.image = nil
        productNameLabel.text = nil
        productDateLabel.text = "some date here"
    }
}
