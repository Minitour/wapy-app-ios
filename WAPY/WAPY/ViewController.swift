//
//  ViewController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 20/03/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit
import Firebase
import AZTabBar

class ViewController: UIViewController {

    var didSetupViews = false

    var tabBar: AZTabBarController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let window = Window(start: Point3d(x: 0.0, y: 0.0, z: 0.0), end: Point3d(x: 0.0, y: 0.0, z: 0.0))
//        let box = Box(euler: Point3d(x: 0.0, y: 0.0, z: 0.0))
//        var objects = [TrackableObject]()
//        objects.append(TrackableObject(id: "first object", r: 0.2, position: Point3d(x: 0.0, y: 0.0, z: 0.0)))
//        objects.append(TrackableObject(id: "second object", r: 0.3, position: Point3d(x: 0.0, y: 0.0, z: 0.0)))
//        let mmo = MapModelObject(window: window, camera: box, objects: objects)
//        let camera = CameraRef(mmo: mmo, owner_uid: "some owner id", version: "1.3.2", ipv6: "some mac address")

        setupInterface()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //showARController()

        if !didSetupViews {
            //showCalibrationController() // remove later
            showARController()
            handleAuth()
        }
    }

    func handleAuth() {
        if let user = Auth.auth().currentUser {
            // show home screen
            print(user.uid)
            normalLoad()
        } else {
            // show guest controller
            let guestController = GuestViewController()
            let navController = UINavigationController(rootViewController: guestController)
            self.present(navController, animated: true)
        }
    }

    func setupInterface() {
        guard !didSetupViews else { return }

        tabBar = .insert(into: self, withTabIcons: [#imageLiteral(resourceName: "baseline_style_black_24pt"),#imageLiteral(resourceName: "baseline_store_black_24pt"),#imageLiteral(resourceName: "baseline_account_circle_black_24pt")])

        tabBar.defaultColor = .lightGray
        tabBar.selectedColor = #colorLiteral(red: 0.1607843137, green: 0.6862745098, blue: 0.6823529412, alpha: 1)
        tabBar.selectionIndicatorColor = #colorLiteral(red: 0.1607843137, green: 0.6862745098, blue: 0.6823529412, alpha: 1)
        tabBar.selectionIndicatorHeight = 2.0
        tabBar.setTitle("Products", atIndex: 0)
        tabBar.setTitle("Stores", atIndex: 1)
        tabBar.setTitle("Account", atIndex: 2)

        tabBar.animateTabChange = true
    }

    func normalLoad() {
        tabBar.setViewController(UIViewController(), atIndex: 0)
        tabBar.setViewController(UIViewController(), atIndex: 1)
        //tabBar.setViewController(UIViewController(), atIndex: 2)

        tabBar.setAction(atIndex: 2) { [unowned self] in
            let controller = ConnectController()
            let navController = UINavigationController(rootViewController: controller)

            self.present(navController, animated: true, completion: nil)
        }

        didSetupViews = true
    }

    func showARController() {
        // The first task
        let task1 = Task(info: "Please look around", details: "Keep looking around in order to give the camera a better indication of where everything is. Look at the ground, at the walls, at the objects around.", completed: false)

        // find the camera
        let task2 = Task(info: "Find the camera", details: "Please look at the camera until you are prompted to continue.", completed: false)

        // mark the products
        let task3 = Task(info: "Mark your products", details: "Go up to your product with your phone. Get really close as if your device is physically touching the item and then touch and hold the screen, then slowly bring your phone back and forward to mark the radius. After creating the circle tap it to identify your product.", completed: false)

        // review everything
        let task5 = Task(info: "Review", details: "Go ahead and look around to see if this is everything you wanted. After this you cannot make any modifications.", completed: false)

        let controller = RoomMapController()

        controller.taskManager.addTask(task1)
        controller.taskManager.addTask(task2)
        controller.taskManager.addTask(task3)
        //controller.taskManager.addTask(task4)
        controller.taskManager.addTask(task5)

        present(controller, animated: true, completion: nil)
    }

    func showCalibrationController() {
        let controller = ConnectController()
        let navController = UINavigationController(rootViewController: controller)

        self.present(navController, animated: true, completion: nil)
    }
}

