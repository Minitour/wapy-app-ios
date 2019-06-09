//
//  ProfileViewController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 09/06/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit
import Eureka
import FirebaseAuth
import FirebaseFirestore

public class ProfileViewController: FormViewController {
    let db = Firestore.firestore()

    var logoutClosure: (() ->  Void)?

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = "Profile"
        let user = Auth.auth().currentUser!

        form +++ Section()
            <<< ProfileRow(){ row in

                row.profileName = user.displayName
                row.profileImage = user.photoURL
                row.cell.height = { 100 }
        }

            <<< LabelRow() { row in
                row.title = "Email"
                row.value = user.email
        }

        +++ Section("Stats")
            <<< LabelRow() { row in
                row.title = "Stores"
                row.value = "Loading..."

                db.collection("stores")
                    .whereField("owner_uid", isEqualTo: user.uid)
                    .getDocuments(source: .default) { (querySnapshot, err) in
                        guard let queryResult = querySnapshot else {
                            row.value = "Unknown"
                            return
                        }
                        row.value = "\(queryResult.count)"
                        row.updateCell()
                }
        }

        <<< LabelRow() { row in
                row.title = "Cameras"
                row.value = "Loading..."

                db.collection("cameras")
                    .whereField("owner_uid", isEqualTo: user.uid)
                    .getDocuments(source: .default) { (querySnapshot, err) in
                        guard let queryResult = querySnapshot else {
                            row.value = "Unknown"
                            return
                        }
                        row.value = "\(queryResult.count)"
                        row.updateCell()
                }
        }

        <<< LabelRow() { row in
                row.title = "Products"
                row.value = "Loading..."

                db.collection("products")
                    .whereField("owner_uid", isEqualTo: user.uid)
                    .getDocuments(source: .default) { (querySnapshot, err) in
                        guard let queryResult = querySnapshot else {
                            row.value = "Unknown"
                            return
                        }
                        row.value = "\(queryResult.count)"
                        row.updateCell()
                }
        }

        +++ Section("Address")
            <<< LabelRow("street_row") { row in
            row.title = "Street"
            row.value = "..."
        }
            <<< LabelRow("city_row") { row in
                row.title = "City"
                row.value = "..."
        }
            <<< LabelRow("country_row") { row in
                row.title = "Country"
                row.value = "..."
        }
            <<< LabelRow("postal_row") { row in
                row.title = "Postal"
                row.value = "..."
        }

        +++ Section("About")
            <<< TextAreaRow("about_row") { row in
                row.cell.height = { 200 }

        }

        +++ Section()
            <<< ButtonRow().cellSetup { cell, row  in
                cell.tintColor = .red
                row.title = "Logout"
                }.onCellSelection { [unowned self] cell, row in
                    self.didSelectLogout()
                }

        db.collection("users").document(user.uid).getDocument { [weak self] (doc, err) in
            guard let self = self else { return }
            guard let data = doc?.data() else { return }

            (self.form.rowBy(tag: "street_row") as? LabelRow)?.value = "\(data["address"] ?? "")"
            (self.form.rowBy(tag: "street_row") as? LabelRow)?.updateCell()

            (self.form.rowBy(tag: "city_row") as? LabelRow)?.value = "\(data["city"] ?? "")"
            (self.form.rowBy(tag: "city_row") as? LabelRow)?.updateCell()

            (self.form.rowBy(tag: "country_row") as? LabelRow)?.value = "\(data["country"] ?? "")"
            (self.form.rowBy(tag: "country_row") as? LabelRow)?.updateCell()

            (self.form.rowBy(tag: "postal_row") as? LabelRow)?.value = "\(data["postalCode"] ?? "")"
            (self.form.rowBy(tag: "postal_row") as? LabelRow)?.updateCell()

            (self.form.rowBy(tag: "about_row") as? TextAreaRow)?.value = "\(data["about"] ?? "")"
            (self.form.rowBy(tag: "about_row") as? TextAreaRow)?.updateCell()
        }

    }

    func didSelectLogout() {
        logoutClosure?()
    }
}
