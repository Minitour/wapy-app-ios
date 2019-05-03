//
//  TrackableObject.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 12/04/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import Foundation

public class TrackableObject: Codable {
    var id: String
    var r: Float
    var position: Point3d

    init(id: String, r: Float, position: Point3d) {
        self.id = id
        self.r = r
        self.position = position
    }
}
