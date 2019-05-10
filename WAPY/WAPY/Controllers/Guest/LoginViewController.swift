//
//  LoginViewController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 12/04/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import AZDialogView

public class LoginViewController: FormViewController {

    var isLogin = true

    var currentDialog: AZDialogViewController?

    lazy var callback: AuthDataResultCallback = { res,err in
        if let err = err {
            self.currentDialog?.title = "Error"
            self.currentDialog?.message = err.localizedDescription
            return
        }

        self.currentDialog?.dismiss(animated: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = self.isLogin ? "Login" : "Register"

        let section = Section()

        form +++
        section

        if !isLogin {
            // show name row
            section
            <<<
            NameRow("name") {
                $0.placeholder = "Your name"
            }
        }

        section
        <<< EmailRow("email") {
            $0.placeholder = "Email"
        }

        section
        <<< PasswordRow("password"){
            $0.placeholder = "Password"
        }

        form
        +++
        Section()
        <<< ButtonRow()
        .cellSetup { cell, row in
            row.title = self.isLogin ? "Login" : "Register"

        }.onCellSelection { cell, row in

            self.currentDialog = AZDialogViewController(title: "Loading...",message: "This will take a second...")
            self.currentDialog?.show(in: self)

            let email = (self.form.rowBy(tag: "email") as! EmailRow).value ?? ""
            let password = (self.form.rowBy(tag: "password") as! PasswordRow).value ?? ""

            if self.isLogin {
                Auth.auth().signIn(withEmail: email, password: password,completion: self.callback)
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.photoURL
                }
            }

        }
    }
}
