//
//  StoresRemoteDataSource.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 09/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit
import AZRemoteTable
import Kingfisher


public class StoresRemoteDataSource: AZRemoteTableDataSource {
    var data: [Store] = []

    public override func numberOfRowsInSection(_ tableView: UITableView, section: Int) -> Int {
        return data.count
    }

    /// Helper function to add items.
    public func addItems(items: [Store]){
        for item in items { self.data.append(item) }
    }

    /// Helper function to clear items.
    public func clearItems() {
        data.removeAll()
        reset()
    }

    public override func cellForRowAt(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! StoreItemCell

        let store = data[indexPath.row]

        cell.storeName.text = store.name

        if let image = store.image, let url = URL(string: image) {
            // get image as url
            // use kingfisher
            // set image
            cell.storeImage.kf.setImage(with: url)
        }

        return cell
    }
}
