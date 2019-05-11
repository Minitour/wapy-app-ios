//
//  ProductRemoteDataSource.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 03/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import AZRemoteTable
import UIKit
import Kingfisher


public class ProductRemoteDataSource: AZRemoteTableDataSource {
    var data: [Product] = []

    public override func numberOfRowsInSection(_ tableView: UITableView, section: Int) -> Int {
        return data.count
    }

    /// Helper function to add items.
    public func addItems(items: [Product]){
        for item in items { self.data.append(item) }
    }

    /// Helper function to clear items.
    public func clearItems() {
        data.removeAll()
        reset()
    }

    public override func cellForRowAt(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ProductItemCell

        let product = data[indexPath.row]

        cell.productNameLabel.text = product.name

        if let image = product.image, let url = URL(string: image) {
            cell.productImage.kf.setImage(with: url)
        }

        return cell
    }
}
