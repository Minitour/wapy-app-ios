//
//  MapModelObject.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 12/04/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import Foundation

public struct MapModelObject: Codable {

    /// The camera box which contains it's euler angles.
    var camera: Box

    /// The trackable objects.
    var objects: [TrackableObject]
}
