//
//  CameraItemCell.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 15/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit

public class CameraItemCell: UITableViewCell {
    var cameraHeatMapImage: UIImageView!
    var cameraNameLabel: UILabel!
    var cameraVersionLabel: UILabel!

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
        cameraHeatMapImage = UIImageView()
        cameraNameLabel = UILabel()
        cameraVersionLabel = UILabel()

        cameraHeatMapImage.contentMode = .scaleAspectFill
        cameraHeatMapImage.layer.masksToBounds = true

        cameraNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        cameraVersionLabel.font = UIFont.systemFont(ofSize: 13)

        cameraVersionLabel.textColor = .gray

        cardView.cornerRadius = 15.0
        cardView.layer.masksToBounds = true
        cardView.backgroundColor = .white

        // layout store image view
        cardView.addSubview(cameraHeatMapImage)
        cameraHeatMapImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraHeatMapImage.topAnchor.constraint(equalTo: cardView.topAnchor),
            cameraHeatMapImage.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            cameraHeatMapImage.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            cameraHeatMapImage.heightAnchor.constraint(equalTo: cardView.heightAnchor,multiplier: 0.7)
            ])

        // layout store name label

        let stackView = UIStackView(arrangedSubviews: [cameraNameLabel,cameraVersionLabel])
        stackView.axis = .vertical

        cardView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: cameraHeatMapImage.bottomAnchor,constant: 8.0),
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
}
