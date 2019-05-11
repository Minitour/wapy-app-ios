//
//  Network.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 11/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import Foundation

struct Network: Codable {
    var mac: String?
    var bssid: String?
    var ssid: String?
    var channel: Int?
    var frequency: Int?
    var signal_level: Float?
    var quality: Int?
    var security: String?
    var security_flags: String?
    var mode: String?
}
