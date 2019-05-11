//
//  CreateBoxController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 03/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit
import Eureka

public class CreateBoxController: FormViewController {

    lazy var service = CalibrationService.shared

    var mmo: MapModelObject? {
        didSet{
            // mark MMO as set.
            print(mmo)
            //TODO: update ui
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        form
        +++
        Section()
        <<<
        TextRow("name_row").cellSetup { cell, row in
            row.title = "Name"
        }
        <<<
        ButtonRow().cellSetup { cell,row in
            row.title = "Select Store"
        }
        +++
        Section()
        <<<
        ButtonRow().cellSetup { cell,row in
            row.title = "Continue"
        }.onCellSelection { [unowned self] cell, row in
            self.didSelectScan()
        }
    }

    func didSelectScan() {
        // start AR controller
        let task1 = Task(info: "Please look around", details: "Keep looking around in order to give the camera a better indication of where everything is. Look at the ground, at the walls, at the objects around.", completed: false)

        // find the camera
        let task2 = Task(info: "Find the camera", details: "Please look at the camera until you are prompted to continue.", completed: false)

        // mark the products
        let task3 = Task(info: "Mark your products", details: "Go up to your product with your phone. Get really close as if your device is physically touching the item and then touch and hold the screen, then slowly bring your phone back and forward to mark the radius. After creating the circle tap it to identify your product.", completed: false)

        // review everything
        let task4 = Task(info: "Take a picture", details: "Rotate your phone to the left and try to maintain a 90º angle for few seconds while looking at the camera directly.", completed: false)

        let controller = RoomMapController()
        controller.delegate = self

        controller.taskManager.addTask(task1)
        controller.taskManager.addTask(task2)
        controller.taskManager.addTask(task3)
        controller.taskManager.addTask(task4)

        present(controller, animated: true, completion: nil)
    }
}

extension CreateBoxController: RoomMapControllerDelegate {
    public func didFinishCalibration(_ controller: RoomMapController,
                                     products: [TrackableObject], cameraObject: Box) {

        controller.dismiss(animated: true) {
            self.mmo = MapModelObject(camera: cameraObject, objects: products)
            let name = (self.form.rowBy(tag: "name_row") as? TextRow)?.value
            // upload data to firebase
            API.shared.createCamera(name: name, storeId: nil, version: "0.0.1", mmo: self.mmo) { id, error in
                // send notify using bluetooth
                if let id = id {
                    print("got the id \(id)")
                    self.service.updateCameraId(id) { service in

                        // dismiss the navigation controller.
                        self.dismiss(animated: true) {
                            //do some table reloading stuff
                        }
                    }
                } else {
                    // TODO: show error
                    print(error)
                }

            }
        }
    }
}
