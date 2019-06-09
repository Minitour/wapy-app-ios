//
//  GuestViewController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 12/04/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit


public class GuestViewController: UIViewController {

    var loginBtn: ProgressiveButton!
    var registerBtn: ProgressiveButton!

    public override func loadView() {
        super.loadView()

        title = "Welcome"
        navigationController?.navigationBar.prefersLargeTitles = true

        self.view.backgroundColor = .white
        loginBtn = ProgressiveButton()//UIButton(type: .system)
        registerBtn = ProgressiveButton() //UIButton(type: .system)

        styleButton(loginBtn)
        styleButton(registerBtn)

        let stackView = UIStackView(arrangedSubviews: [loginBtn,registerBtn])
        stackView.axis = .vertical
        stackView.spacing = 20.0
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "wapy_logo_hd")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        let label = UILabel()
        label.text = "A platform which provides you with better analytical insight as to what is going on in your store front display windows."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16)

        let iconStackView = UIStackView(arrangedSubviews: [imageView,label])
        iconStackView.axis = .vertical
        iconStackView.spacing = 16.0
        iconStackView.distribution = .fill
        iconStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        view.addSubview(iconStackView)

        NSLayoutConstraint.activate([
            iconStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16.0),
            iconStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16.0),
            imageView.heightAnchor.constraint(equalToConstant: 100.0),
            imageView.widthAnchor.constraint(equalToConstant: 100.0),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -32.0),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16.0),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16.0),
            stackView.heightAnchor.constraint(equalToConstant: 100)
        ])


        loginBtn.setTitle("Login", for: [])
        registerBtn.setTitle("Register", for: [])

        loginBtn.addTarget(self, action: #selector(didSelectLogin(_:)), for: .touchUpInside)
        registerBtn.addTarget(self, action: #selector(didSelectRegister(_:)), for: .touchUpInside)


        self.navigationItem.hidesBackButton = true
    }

    func styleButton(_ button: ProgressiveButton) {
        button.status = .next
        button.isRounded = true
        button.animateInteraction = true
        button.color = COLOR_PRIMARY
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowRadius = 4
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
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
