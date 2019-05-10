//
//  StoreItemCell.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 09/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit

public class StoreItemCell: UITableViewCell {
    var storeImage: UIImageView!
    var storeName: UILabel!

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
        storeImage = UIImageView()
        storeName = UILabel()

        storeImage.contentMode = .scaleToFill

        storeName.font = UIFont.boldSystemFont(ofSize: 24)

        cardView.cornerRadius = 15.0
        cardView.layer.masksToBounds = true
        cardView.backgroundColor = .white

        // layout store image view
        cardView.addSubview(storeImage)
        storeImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            storeImage.topAnchor.constraint(equalTo: cardView.topAnchor),
            storeImage.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            storeImage.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            storeImage.heightAnchor.constraint(equalTo: cardView.heightAnchor,multiplier: 0.75)
        ])

        // layout store name label
        cardView.addSubview(storeName)
        storeName.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            storeName.topAnchor.constraint(equalTo: storeImage.bottomAnchor),
            storeName.leadingAnchor.constraint(equalTo: cardView.leadingAnchor,constant: 8.0),
            storeName.trailingAnchor.constraint(equalTo: cardView.trailingAnchor,constant: -8.0),
            storeName.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
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
}
