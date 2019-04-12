//
//  GuestViewController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 12/04/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit


public class GuestViewController: UIViewController {

    var loginBtn: UIButton!
    var registerBtn: UIButton!

    public override func loadView() {
        super.loadView()

        self.view.backgroundColor = .white
        loginBtn = UIButton(type: .system)
        registerBtn = UIButton(type: .system)

        let stackView = UIStackView(arrangedSubviews: [loginBtn,registerBtn])
        stackView.axis = .vertical
        stackView.spacing = 16.0

        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16.0),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16.0)
        ])

        loginBtn.setTitle("Login", for: [])
        registerBtn.setTitle("Register", for: [])

        loginBtn.addTarget(self, action: #selector(didSelectLogin(_:)), for: .touchUpInside)
        registerBtn.addTarget(self, action: #selector(didSelectRegister(_:)), for: .touchUpInside)
    }

    @objc func didSelectLogin(_ sender: UIButton) {
        self.navigationController?.pushViewController(LoginViewController(), animated: true)
    }

    @objc func didSelectRegister(_ sender: UIButton) {
        let controller = LoginViewController()
        controller.isLogin = false
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
