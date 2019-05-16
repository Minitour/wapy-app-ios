//
//  Camera.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 12/04/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import Foundation

public struct Camera: Codable{

    var name: String?

    var id: String?

    var image: String?

    var heatmap: [HeatMapItem]?

    /// The mmo object.
    var mmo: MapModelObject?

    /// The owner uid.
    var owner_uid: String?

    /// The version the box is currently running.
    var version: String?

    /// The MAC address of the box.
    var ipv6: String?

    var secret: String?
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
