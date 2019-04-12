//
//  MapModelObject.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 12/04/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import Foundation

struct MapModelObject: Codable {

    /// The window object.
    var window: Window

    /// The camera box which contains it's euler angles.
    var camera: Box

    /// The trackable objects.
    var objects: [TrackableObject]
}
