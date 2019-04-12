//
//  TrackableObject.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 12/04/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import Foundation

struct TrackableObject: Codable {
    var id: String
    var r: Float
    var position: Point3d
}
