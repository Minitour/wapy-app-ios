//
//  Store.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 09/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import Foundation

public class Store: Codable,Equatable {
    public static func == (lhs: Store, rhs: Store) -> Bool {
        return lhs.id == rhs.id
    }

    var id: String?
    var name: String?
    var image: String?
    var ownerId: String?

    init(id: String?, name: String?, image: String?,ownerId: String?) {
        self.id = id
        self.name = name
        self.image = image
        self.ownerId = ownerId
    }
}
