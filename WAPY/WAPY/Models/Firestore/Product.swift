//
//  Product.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 03/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import Foundation

public class Product {
    var id: String?
    var name: String?
    var image: String?

    init(id: String?, name: String?, image: String?) {
        self.id = id
        self.name = name
        self.image = image
    }
}
