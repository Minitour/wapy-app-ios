//
//  CameraInfo.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 15/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import Foundation
/**
 'version' : version,
 'name' : name,
 'calibrated' : isCalibrated,
 'network': ssid
 */
struct CameraInfo: Codable {
    var id: String?
    var calibrated: Bool
    var authenticated: Bool
    var version: String?
    var name: String?
    var network: String?
    
    var isConnected: Bool {
        return network != nil
    }
}
