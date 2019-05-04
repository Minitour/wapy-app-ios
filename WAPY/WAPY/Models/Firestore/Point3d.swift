//
//  Point3D.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 12/04/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import Foundation

class Point3d: Codable {
    var x: Float
    var y: Float
    var z: Float

    init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }

}

extension Point3d: CustomStringConvertible {
    public var description: String { return "\(x),\(y),\(z)" }
}
