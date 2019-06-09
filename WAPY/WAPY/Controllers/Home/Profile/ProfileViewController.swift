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

public class ProfileViewController: FormViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()


        form +++ Section()
            <<< ProfileRow(){ row in

                row.profileName = Auth.auth().currentUser?.displayName
                row.profileImage = Auth.auth().currentUser?.photoURL
                row.cell.height = { 100 }
        }
    }
}
