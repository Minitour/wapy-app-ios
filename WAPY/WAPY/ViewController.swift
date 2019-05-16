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

        setupInterface()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !didSetupViews {
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
        tabBar.setViewController(UINavigationController(rootViewController: ProductsViewController()), atIndex: 0)
        tabBar.setViewController(UINavigationController(rootViewController: StoresViewController()), atIndex: 1)
        //tabBar.setViewController(UIViewController(), atIndex: 2)

        tabBar.setAction(atIndex: 2) { [unowned self] in
            self.showARController()
//            let controller = ConnectController()
//            let navController = UINavigationController(rootViewController: controller)
//
//            self.present(navController, animated: true, completion: nil)
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
        controller.taskManager.addTask(task5)

        controller.delegate = self

        present(controller, animated: true, completion: nil)
    }

    func showCalibrationController() {
        let controller = ConnectController()
        let navController = FlexibleNavigationController(rootViewController: controller)


        self.present(navController, animated: true, completion: nil)
    }
}

extension ViewController: RoomMapControllerDelegate {
    func didFinishCalibration(_ controller: RoomMapController,
                              products: [TrackableObject],
                              cameraObject: Box,
                              capturedImage: UIImage?,
                              heatMapElements: [HeatMapItem]?) {

        controller.dismiss(animated: true, completion: nil)

        let mmo = MapModelObject(camera: cameraObject, objects: products)

        var data = [String: Any]()

        data["storeId"] = "fakeStoreId"
        data["version"] = "0.0.1"
        data["name"] = "fakeName"
        data["mmo"] = mmo.dictionary
        data["image"] = "fakeImageUrl"
        if let heatMapItems = heatMapElements {
            var heatMapData = [[String:Any]]()
            for item in heatMapItems {
                guard let item = item.dictionary else { continue }
                heatMapData.append(item)
            }
            data["heatmap"] = heatMapData
        }

        data["id"] = "fakeCameraId"

        if let json = data.jsonStringRepresentation {
            print(json)
        }
        
    }
}
