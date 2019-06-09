//
//  ProfileRow.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 09/06/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit
import Eureka
import Kingfisher

// Custom Cell with value type: Bool
// The cell is defined using a .xib, so we can set outlets :)
public class ProfileViewCell: Cell<Bool>, CellType {

    open var profileImageView: UIImageView!
    open var profileTitleLabel: UILabel!

    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        profileImageView = UIImageView()
        profileTitleLabel = UILabel()

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(profileImageView)
        self.contentView.addSubview(profileTitleLabel)

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor,constant: 8.0),
            profileImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8.0),
            profileImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8.0),
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor),
            profileTitleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8.0),
            profileTitleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,constant: -8.0),
            profileTitleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])

        selectionStyle = .none

        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 42.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    public override func update() {
        super.update()
    }

}

// The custom Row also has the cell: CustomCell and its correspond value
public final class ProfileRow: Row<ProfileViewCell>, RowType {

    var profileName: String? {
        set {
            self.cell?.profileTitleLabel?.text = newValue
        }get {
            return self.cell?.profileTitleLabel?.text
        }
    }

    var profileImage: URL? {
        set {
            guard let imageView = self.cell?.profileImageView else { return }
            guard let url = newValue else {
                imageView.image = #imageLiteral(resourceName: "no-photo")
                return
            }

            imageView.kf.setImage(with: url)
        } get {
            return nil
        }
    }

    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ProfileViewCell>()
    }
}

