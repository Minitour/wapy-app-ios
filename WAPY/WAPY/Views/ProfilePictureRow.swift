//
//  ProfilePictureRow.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 09/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit
import Eureka

public class ProfilePictureCell: Cell<UIImage>, CellType {



    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func setup() {
        super.setup()

    }

    public override func update() {
        // super.update()
        // apply UI updates if needed.
    }

    public override func setHighlighted(_ highlighted: Bool, animated: Bool) {

    }
}

public final class ProfilePictureRow: Row<ProfilePictureCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ProfilePictureCell>()
    }


}
