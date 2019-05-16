//
//  CreateBoxController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 03/05/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit
import Eureka
import AZDialogView

public class CreateBoxController: FormViewController {

    lazy var dialog: AZDialogViewController = loadingDialog(title: "Loading...")
    lazy var service = CalibrationService.shared

    var store: Store?
    var camera: Camera?
    var mmo: MapModelObject?

    var isUpdateMode: Bool {
        return camera != nil
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        form
        +++
        Section()
        <<<

        // The name row
        TextRow("name_row").cellSetup { cell, row in
            row.title = "Name"
            row.value = self.camera?.name
        }
        <<<

        // The store row
        StoreRow("store_row").cellSetup {[unowned self] cell,row in
            row.title = "Select Store"
            row.value = self.store
            if row.value == nil {
                row.disabled = true
            }
        }

        let section = Section()
        <<<

        // The scan button
        ButtonRow().cellSetup { cell,row in
            row.title = self.isUpdateMode ? "Scan and Update" : "Start Scanning"
        }.onCellSelection { [unowned self] cell, row in
            self.didSelectScan()
        }

        form +++ section

        if isUpdateMode {
            section
            <<<
            ButtonRow().cellSetup { cell, row in
                row.title = "Update Without Scan"
            }.onCellSelection {[unowned self] cell, row in
                self.onUpdateOnly()
            }

            self.navigationItem.rightBarButtonItem =
                UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didSelectCancel))
        }

        self.title = isUpdateMode ? "Update Camera" : "Create Camera"
    }

    func onUpdateOnly() {
        let name = (self.form.rowBy(tag: "name_row") as? TextRow)?.value
        let store = (self.form.rowBy(tag: "store_row") as? StoreRow)?.value

        dialog.show(in: self)
        dialog.title = "Updating..."
        API.shared.updateCamera(cameraId: camera!.id!,
                                name: name,
                                storeId: store?.id,
                                version: "0.0.1",
                                mmo: nil,
                                heatMapItems: nil,
                                imageUrl: nil) { (success, error) in
                                    guard let secret = self.camera?.secret else { return }
                                    self.service.requestCameraUpdate(secret: secret) { service, err in
                                        self.finish()
                                    }
        }
    }

    @objc func didSelectCancel() {
        self.dismiss(animated: true) {
            self.service.disconnect()
        }
    }

    func didSelectScan() {
        // start AR controller
        let task1 = Task(info: "Please look around",
                         details: "Keep looking around in order to give the camera a better indication of where everything is. Look at the ground, at the walls, at the objects around.",
                         completed: false)

        // find the camera
        let task2 = Task(info: "Find the camera",
                         details: "Please look at the camera until you are prompted to continue.",
                         completed: false)

        // mark the products
        let task3 = Task(info: "Mark your products",
                         details: "Go up to your product with your phone. Get really close as if your device is physically touching the item and then touch and hold the screen, then slowly bring your phone back and forward to mark the radius. After creating the circle tap it to identify your product.",
                         completed: false)

        // review everything
        let task4 = Task(info: "Take a picture",
                         details: "Rotate your phone to the left and try to maintain a 90º angle for few seconds while looking at the camera directly.",
                         completed: false)

        let controller = RoomMapController()
        controller.delegate = self
        controller.taskManager.addTask(task1)
        controller.taskManager.addTask(task2)
        controller.taskManager.addTask(task3)
        controller.taskManager.addTask(task4)

        //present(controller, animated: true, completion: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension CreateBoxController: RoomMapControllerDelegate {

    public func didFinishCalibration(_ controller: RoomMapController, products: [TrackableObject],
                                     cameraObject: Box, capturedImage: UIImage?, heatMapElements: [HeatMapItem]?) {
        self.navigationController?.popViewController(animated: true)

        self.mmo = MapModelObject(camera: cameraObject, objects: products)
        let name = (self.form.rowBy(tag: "name_row") as? TextRow)?.value
        let store = (self.form.rowBy(tag: "store_row") as? StoreRow)?.value

        // upload data to firebase
        guard let image = capturedImage else { return }

        dialog.show(in: self)
        dialog.title = "Uploading image"
        self.uploadImage(image, name: name, store: store, heatMapElements: heatMapElements)
    }

    func uploadImage(_ image: UIImage, name: String?, store: Store?, heatMapElements: [HeatMapItem]?) {
        // upload image then
        API.shared.upload(image: image) { (url, err) in
            if self.isUpdateMode {
                // update camera
                DispatchQueue.main.async { self.dialog.title = "Updating Camera" }
                self.updateCamera(url: url,
                                  name: name,
                                  store: store,
                                  heatMapElements: heatMapElements)
            } else {
                // create camera
                DispatchQueue.main.async { self.dialog.title = "Registering Camera" }
                self.createCamera(url: url,
                                  name: name,
                                  store: store,
                                  heatMapElements: heatMapElements)
            }
        }
    }

    func updateCamera(url: URL?, name: String?, store: Store?, heatMapElements: [HeatMapItem]?) {

        // Make api call to update the camera
        API.shared.updateCamera(cameraId: camera!.id!,
                                name: name,
                                storeId: store?.id,
                                version: "0.0.1",
                                mmo: self.mmo,
                                heatMapItems: heatMapElements,
                                imageUrl: url?.absoluteString) { [weak self] (ok, err) in
                                    guard let `self` = self else { return }
                                    guard let secret = self.camera?.secret else { return }

                                    // if everything is ok continue for bluetooth update
                                    guard ok else { return }

                                    // request camera to update itself.
                                    self.service.requestCameraUpdate(secret: secret) { service, err in
                                        self.finish()
                                    }
        }
    }

    func createCamera(url: URL?, name: String?, store: Store?, heatMapElements: [HeatMapItem]?) {
        // create camera
        API.shared.createCamera(name: name,
                                storeId: store?.id,
                                version: "0.0.1",
                                mmo: self.mmo,
                                heatMapItems: heatMapElements,
                                imageUrl: url?.absoluteString) { id, error in

                                    // send notify using bluetooth
                                    if let id = id {
                                        print("got the id \(id)")
                                        self.service.updateCameraId(id) { service, err in
                                            self.finish()
                                        }
                                    } else {
                                        // TODO: show error
                                        if let error = error { print(error) }
                                    }

        }
    }

    func finish() {
        DispatchQueue.main.async {
            self.dialog.dismiss(animated: true) {
                self.dismiss(animated: true) {
                    self.service.disconnect()
                }
            }
        }
    }

}
