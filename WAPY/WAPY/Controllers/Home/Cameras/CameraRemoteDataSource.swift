//
//  CameraRemoteDataSource.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 15/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import AZRemoteTable
import UIKit
import Kingfisher


public class CameraRemoteDataSource: AZRemoteTableDataSource {
    var data: [Camera] = []

    public override func numberOfRowsInSection(_ tableView: UITableView, section: Int) -> Int {
        return data.count
    }

    /// Helper function to add items.
    public func addItems(items: [Camera]){
        for item in items { self.data.append(item) }
    }

    /// Helper function to clear items.
    public func clearItems() {
        data.removeAll()
        reset()
    }

    public override func cellForRowAt(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CameraItemCell

        let camera = data[indexPath.row]

        cell.cameraNameLabel.text = camera.name
        cell.cameraVersionLabel.text = camera.version

        if let image = camera.image, let url = URL(string: image) {
            cell.cameraHeatMapImage.kf.setImage(with: url)
        }else {
            cell.cameraHeatMapImage.image = #imageLiteral(resourceName: "image_placeholder")
        }

        return cell
    }
}
