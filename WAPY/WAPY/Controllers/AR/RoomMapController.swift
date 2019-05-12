//
//  RoomMapController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 30/03/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit
import ARKit
import VideoToolbox
import FlexibleSteppedProgressBar
import PKHUD
import AZDialogView


public protocol RoomMapControllerDelegate: class {
    func didFinishCalibration(_ controller: RoomMapController,
                              products: [TrackableObject],
                              cameraObject: Box,
                              capturedImage: UIImage?,
                              heatMapElements: [HeatMapItem]?)
}

enum CalibrationPhase: Int {
    case plane
    case camera
    case product
    case window
    case overview
}

enum CameraFacingCheckResult {
    case success(CVPixelBuffer, [String : SCNVector3], CGSize) // all good
    case invalidOrientation // the orientation is not in the specified range.
    case boxNotDetectedYet // The box has not been detected yet
    case boxNotInCenter // The box is not in the center of the device
    case notInFrontOfBox // not in the line of sight of the box.
    case error // generic error
}

public class RoomMapController: UIViewController {

    public override var prefersStatusBarHidden: Bool {
        return true
    }

    var taskManager: TaskManager = TaskManager()

    /// The AR Config
    var sessionConfig: ARWorldTrackingConfiguration {
        let config = ARWorldTrackingConfiguration()
        config.isAutoFocusEnabled = true
        config.planeDetection = [.horizontal,.vertical]
        config.environmentTexturing = .automatic
        guard let referenceObjects = ARReferenceObject
            .referenceObjects(inGroupNamed: "the_box", bundle: nil) else {
                fatalError("Missing expected asset catalog resources.")
        }
        config.detectionObjects = referenceObjects
        return config
    }

    open weak var delegate: RoomMapControllerDelegate?

    // MARK: - Constants

    let numberOfPlanesNeeded: Int = 5

    let padding: CGFloat = 16.0

    let buttonHeight: CGFloat = 55.0

    let progressBarHeight: CGFloat = 40.0

    // MARK: - Views

    /// The main scene view
    var sceneView: ARSCNView!

    /// Reset stage button
    var resetButton: GlassButton!

    /// Get more info button
    var infoButton: GlassButton!

    /// The progress bar
    var progressBar: FlexibleSteppedProgressBar!

    /// The next button
    var nextButton: UIButton!

    /// A label which displays the instructions for the user.
    var messageLabel: UILabel!

    var secondaryMessageLabel: UILabel!

    // MARK: - State

    /// The current step. Variable is changed from background threads.
    var currentStep: Int = 0 {
        didSet{
            // did step change
            if currentStep == 2 {
                DispatchQueue.main.async {
                   self.nextButton.isEnabled = false
                   self.nextButton.isHidden = false
                }
            }

            if currentStep == 3 {
                DispatchQueue.main.async {
                    self.nextButton.isHidden = true
                }
            }
        }
    }

    /// Number of detected planes so far.
    var numberOfPlanesFound: Int = 0 {
        didSet{
            if currentStep == 0 {
                onDataChanged()
            }
        }
    }

    /// Has the camera been detected
    var cameraDetected: Bool = false

    var autoCounter: Int = 0

    /// The number of products currently tracked
    var numberOfProducts: Int {
        return trackedProducts.count
    }

    // MARK: - Tracked variables

    // ---------------------------------------------------------------
    // PRODUCT TRACKING

    /// the start location, used when adding a product
    var startLocation: SCNVector3?

    /// the cylinder geomtry of the product being added.
    var tempProductGeometry: SCNCylinder?

    /// The currently tracked products
    var trackedProducts: [String : TrackableObject] = [:]

    /// The current selected product id
    var currentSelectedProductId: String?



    // ---------------------------------------------------------------
    // CAMERA TRACKING

    /// The camera object that was detected.
    var refObject: ARReferenceObject?

    /// The reference node for the detected object.
    var refNode: SCNNode?

    /// reference use to check if the box is in the POV of the camera.
    var detectionNode: SCNNode?

    var didSetFOV: Bool = false

    /// A variable which tells us if the 3d object is currently visible to the user.
    var objectVisable: Bool = false {
        didSet{
            // observer for later use
            print("is visable: \(objectVisable)")
            if currentStep == 1 {
                onDataChanged()
            }
        }
    }

    var povNode: SCNNode?

    var heatMapItems: [HeatMapItem]?

    /// A variable which prevents the tracking function from being activated.
    var trackDeviceForFrameState: Bool = true

    var thumbnailFrameState: CameraFacingCheckResult = .error {
        didSet {
            //                let image = UIImage(pixelBuffer: pixelBuffer)
            //                print(image)
            switch thumbnailFrameState {

            case .success(let pixelBuffer, let mappingDictionary, let size):
                // pause tracking
                trackDeviceForFrameState = false
                let image = UIImage(pixelBuffer: pixelBuffer)

                DispatchQueue.main.async {
                    self.showDialogWithImage(image: image)
                    self.secondaryMessageLabel.isHidden = true

                }

                // show a dialog with the frame to the user with retake and continue choice.

                // if clicked continue, we'll call the `didSelectNext` function.

                // if clicked retake, resume the tracking.

                heatMapItems = []

                for (k,v) in mappingDictionary {
                    let x1 = v.y
                    let y1 = v.x

                    let percentageX = x1 / Float(size.height)
                    let percentageY = y1 / Float(size.width)


                    let heatMapItem = HeatMapItem(id: k, x: x1, y: y1,
                                                  percentageX: percentageX, percentageY: percentageY)

                    heatMapItems?.append(heatMapItem)
                    
                }

            case .invalidOrientation:
                print("not a valid orientation")
                customMessage("Please rorate your phone to landscape and maintain 90º angle.",isPrimary: true)
            case .boxNotDetectedYet:
                print("box not detected yet")
            case .boxNotInCenter:
                print("Box not in the center")
                customMessage("Keep the box in your line of sight!", isPrimary: false)
            case .notInFrontOfBox:
                print("not in line of sight")
                customMessage("The box should be in the center of your screen!", isPrimary: false)
            case .error:
                print("some error")
            }
        }
    }

    /// The image that will be later used for the heat map.
    var userSelectedFrame: UIImage?

    func showDialogWithImage(image: UIImage?) {
        let dialog = AZDialogViewController(title: "Would you like to use this image?")
        dialog.blurBackground = false
        dialog.customViewSizeRatio = 1.0
        dialog.buttonInit = GLOBAL_BUTTON_INIT
        dialog.buttonStyle = GLOBAL_STYLE

        let container = dialog.container
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit

        container.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        imageView.image = image


        dialog.addAction(AZDialogAction(title: "Yes") { [unowned self] dialog in
            dialog.dismiss(animated: true) {
                self.userSelectedFrame = image
                self.didSelectNext(self.nextButton)
            }
        })

        dialog.addAction(AZDialogAction(title: "Retake") {[unowned self] dialog in
            dialog.dismiss(animated: true) {
                self.heatMapItems = nil
                self.trackDeviceForFrameState = true
            }
        })
        dialog.show(in: self)
    }



    public override func loadView() {
        super.loadView()
        // init views
        sceneView = ARSCNView()
        resetButton = GlassButton()
        infoButton = GlassButton()
        progressBar = FlexibleSteppedProgressBar()
        nextButton = .systemButton(withTitle: "Next")
        messageLabel = PaddingLabel()
        secondaryMessageLabel = PaddingLabel()


        self.view.addSubview(sceneView)
        self.view.addSubview(resetButton)
        self.view.addSubview(infoButton)
        self.view.addSubview(progressBar)
        self.view.addSubview(nextButton)
        self.view.addSubview(messageLabel)
        self.view.addSubview(secondaryMessageLabel)



        // disable auto resizing mask
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryMessageLabel.translatesAutoresizingMaskIntoConstraints = false


        // auto layout
        NSLayoutConstraint.activate([
            resetButton.widthAnchor.constraint(equalToConstant: buttonHeight),
            resetButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -padding),
            resetButton.heightAnchor.constraint(equalTo: resetButton.widthAnchor),
            resetButton.topAnchor.constraint(equalTo: progressBar.bottomAnchor,constant: padding),

            // info button
            infoButton.widthAnchor.constraint(equalToConstant: buttonHeight),
            infoButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -padding),
            infoButton.heightAnchor.constraint(equalTo: infoButton.widthAnchor),
            infoButton.topAnchor.constraint(equalTo: resetButton.bottomAnchor,constant: padding),

            // progress bar
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: padding),
            progressBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: padding),
            progressBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -padding),
            progressBar.heightAnchor.constraint(equalToConstant: progressBarHeight),

            // scene view
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // setup button
            nextButton.heightAnchor.constraint(equalToConstant: 44.0),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: padding * 2),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding * 2),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -padding * 2),

            // setup message label
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: padding),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -padding),
            messageLabel.bottomAnchor.constraint(equalTo: nextButton.topAnchor,constant: -padding),

            secondaryMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: -padding),
            secondaryMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // more customizations
        sceneView.delegate = self

        progressBar.delegate = self
        progressBar.numberOfPoints = taskManager.tasks.count
        progressBar.lineHeight = 9
        progressBar.radius = 15
        progressBar.progressRadius = 20
        progressBar.progressLineHeight = 6
        progressBar.viewBackgroundColor = #colorLiteral(red: 0.9401558042, green: 0.952983439, blue: 0.956292212, alpha: 1)
        progressBar.backgroundShapeColor = #colorLiteral(red: 0.9401558042, green: 0.952983439, blue: 0.956292212, alpha: 1)
        progressBar.centerLayerTextColor = .white
        progressBar.currentSelectedTextColor = .white
        progressBar.currentSelectedCenterColor = #colorLiteral(red: 0.1880986989, green: 0.8226090074, blue: 0.5176928043, alpha: 1)
        progressBar.selectedOuterCircleStrokeColor = .white
        progressBar.selectedBackgoundColor = #colorLiteral(red: 0.1880986989, green: 0.8226090074, blue: 0.5176928043, alpha: 1)
        progressBar.selectedOuterCircleLineWidth = 0.0
        progressBar.centerLayerTextColor = .white
        //progressBar.centerLayerUnselectedTextColor = .gray

        progressBar.currentIndex = 0

        infoButton.tintColor = .white
        resetButton.tintColor = .white
        infoButton.setImage(#imageLiteral(resourceName: "baseline_help_outline_black_36pt"), for: [])
        resetButton.setImage(#imageLiteral(resourceName: "baseline_replay_black_36pt"), for: [])

        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        messageLabel.textColor = .white
        messageLabel.layer.cornerRadius = 3.0
        messageLabel.layer.masksToBounds = true

        secondaryMessageLabel.numberOfLines = 0
        secondaryMessageLabel.lineBreakMode = .byWordWrapping
        secondaryMessageLabel.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        secondaryMessageLabel.textColor = .white
        secondaryMessageLabel.layer.cornerRadius = 3.0
        secondaryMessageLabel.layer.masksToBounds = true

        secondaryMessageLabel.text = "Some static text"
        secondaryMessageLabel.transform = CGAffineTransform(rotationAngle: .pi / 2)
        secondaryMessageLabel.isHidden = true

    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        print(view.bounds)
        resetButton.rounded = true
        infoButton.rounded = true

        resetButton.addTarget(self, action: #selector(didSelectReset(_:)), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(didSelectInfo(_:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didSelectNext(_:)), for: .touchUpInside)

        nextButton.isHidden = true

        let gestureReco = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        gestureReco.minimumPressDuration = 0
        sceneView.addGestureRecognizer(gestureReco)

        // if task exists load it into the view.
        if let _ = taskManager.current() {
            onDataChanged()
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sceneView.session.run(sessionConfig)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        sceneView.session.pause()
    }

    @objc func didSelectReset(_ sender: UIButton) {
        // TODO: reset current step

        // IF last step show full reset dialog.
    }

    @objc func didSelectInfo(_ sender: UIButton) {
        // TODO: show help dialog
    }

    @objc func didSelectNext(_ sender: UIButton) {
        if currentStep == 2 {
            onDataChanged()
            return
        }

        if currentStep == 3 {
            // we are in the last phase and the user clicks the next button:

            let result = normalizedData(cameraCenter: refNode!.worldPosition, euler: refNode!.eulerAngles)
            let objects = result.0
            let box = result.1



            delegate?.didFinishCalibration(self, products: objects,
                                           cameraObject: box,
                                           capturedImage: userSelectedFrame,
                                           heatMapElements: self.heatMapItems)
            onDataChanged()
        }
    }

    /// Function called when frame update. This is a background thread function.
    func didCameraMove(to position: SCNVector3) {

        if currentStep == 2 {
            // change the size of the current object being tracked
            guard let pos = sceneView.session.currentFrame?.camera.transform,
                let startLocation = self.startLocation else { return }
            let currentLocation = SCNVector3(pos.columns.3.x, pos.columns.3.y, pos.columns.3.z)

            let distance = max((startLocation - currentLocation).length(),0.01)
            tempProductGeometry?.radius = CGFloat(distance)
        }
    }


    /// Gesture recognizer function, called when user interacts with the sceneview.
    ///
    /// - Parameter sender: The recognizer.
    @objc func handleTap(_ sender: UITapGestureRecognizer) {

        guard let pos = sceneView.session.currentFrame?.camera.transform else { return }
        let cameraPosition = SCNVector3(pos.columns.3.x, pos.columns.3.y, pos.columns.3.z)

        // on touch begun
        if sender.state == .began {
            
            if currentStep == 2 {

                let location = sender.location(in: sceneView)
                let hitResults = sceneView.hitTest(location, options: [:])

                var nodeName: String?

                if hitResults.count > 0 {
                    // retrieved the first clicked object
                    let tappedPiece = hitResults[0].node
                    nodeName = tappedPiece.name
                }

                // if not product node, start marking a new node.
                if nodeName == nil {
                    startLocation = cameraPosition

                    var translation = matrix_identity_float4x4
                    translation.columns.3.z = -0.05
                    let transform = simd.simd_mul(pos, translation)

                    // add anchor to scene
                    let tempAnchor = ARAnchor(name: "product_node", transform: transform)
                    sceneView.session.add(anchor: tempAnchor)
                }

                // if a product node
                if let name = nodeName, name.contains("product_node") {
                    // product node tapped:
                    guard let obj = trackedProducts[name] else { return }
                    print(obj.dictionary!)

                    // open action dialog
                    manageNode(name: name, trackable: obj, node: hitResults[0].node)
                }
            }
        }

        // on touch end
        if sender.state == .ended {

            if currentStep == 2 {
                if let startLocaiton = self.startLocation {
                    let radius = (startLocaiton - cameraPosition).length()
                    let obj = TrackableObject(id: UUID().uuidString,
                                    r: radius,
                                    position: Point3d(x: startLocaiton.x, y: startLocaiton.y, z: startLocaiton.z))
                    self.addTrackableProduct(obj,nodeId: "product_node_\(autoCounter)")
                    autoCounter += 1

                }
                startLocation = nil
                tempProductGeometry = nil
            }
        }
    }

    /// This function is called when data is changed in the enviorment
    func onDataChanged() {
        guard let currentTask = self.taskManager.current() else { return }

        let message: String = currentTask.info
        var completion: Float = 0

        // step 0 is the step in which we detect planes.
        if self.currentStep == 0 {
            // currently we are looking for new planes
            completion = Float(self.numberOfPlanesFound) / Float(numberOfPlanesNeeded)
        }

        // step 1 is the step in which we detect the camera object.
        if self.currentStep == 1 {
            completion = objectVisable ? 1.0 : 0.0

            if objectVisable {
                if let referenceObject = self.refObject,
                    let node = self.refNode,
                    !didSetFOV {
                    // add pyramid and stuff
                    renderCameraFOV(ref: referenceObject, node: node)

                    // set to nil to avoid adding the object twice.
                    //self.refObject = nil
                    didSetFOV = true
                }
            }
        }

        // step 2 is the step in which we add objects
        if self.currentStep == 2 {
            // must add at least 2 products
            completion = numberOfProducts > 1 ? 1.0 : 0.0
        }

        showMessage(message, completion: completion)
        updateProgress(completion)


    }


    /// Function called on data changed. If the progress is equal or greater to 1.0 then the task will be replaced with the next task.
    ///
    /// - Parameter completion: The progress.
    func updateProgress(_ completion: Float){
        if completion >= 1.0 {
            self.taskManager.didCompleteTask()
            self.currentStep += 1
            onDataChanged()
            DispatchQueue.main.async {
                HUD.flash(.success, delay: 1.0)
                if self.taskManager.tasks.count - 1 != self.progressBar.currentIndex {
                    self.progressBar.currentIndex += 1
                }
            }
        }
    }


    /// Called when its time to update the message on the label.
    ///
    /// - Parameters:
    ///   - message: The message to show
    ///   - completion: The progress
    func showMessage(_ message: String?, completion: Float) {
        guard let message = message else { return }
        let completed = Int(completion * 100)
        DispatchQueue.main.async { [unowned self] in
            self.messageLabel.text = "\(message) \n\nProgress: \(completed)%"
        }
    }

    func customMessage(_ message: String?, isPrimary: Bool) {
        DispatchQueue.main.async { [unowned self] in
            if isPrimary {
                self.messageLabel.text = message
                self.secondaryMessageLabel.isHidden = true
                self.messageLabel.isHidden = false
            } else {
                self.secondaryMessageLabel.text = message
                self.messageLabel.isHidden = true
                self.secondaryMessageLabel.isHidden = false
            }

        }
    }


    /// Add a trackable object to the dictionary
    func addTrackableProduct(_ product: TrackableObject, nodeId: String) {
        self.trackedProducts[nodeId] = product

        if self.trackedProducts.count > 1 {
            self.nextButton.isEnabled = true
        }
    }

    /// Remove a trackable project
    func removeProduct(nodeId: String) {
        self.trackedProducts.removeValue(forKey: nodeId)
        self.nextButton.isEnabled = self.trackedProducts.count > 1
    }

    /// called when a node is tapped
    func manageNode(name: String, trackable: TrackableObject, node: SCNNode) {
        node.geometry?.firstMaterial?.emission.contents = UIColor.yellow

        //TODO: design dialog

        let dialog = AZDialogViewController(title: "Edit Product")
        dialog.blurBackground = false

        dialog.addAction(AZDialogAction(title: "Select Product") { [unowned self] dialog in
            self.currentSelectedProductId = name
            dialog.dismiss(animated: true) {
                self.showProductSelectionController()
            }
        })

        dialog.addAction(AZDialogAction(title: "Delete Product") {[unowned self] dialog in
            self.removeProduct(nodeId: name)
            node.parent?.removeFromParentNode()
            dialog.dismiss()
        })
        dialog.show(in: self)
    }

    /// Show the product selection controller
    func showProductSelectionController() {
        let controller = ProductSelectionController()
        controller.delegate = self

        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .overCurrentContext
        self.present(navController, animated: true, completion: nil)
    }

    /// normalizes the data
    func normalizedData(cameraCenter: SCNVector3, euler: SCNVector3) -> ([TrackableObject], Box) {
        var objects = [TrackableObject]()

        trackedProducts.forEach { objects.append($1) }

        // transform data
        for object in objects {
            let x = transformValue(shiftSize: cameraCenter.x, originalValue: object.position.x)
            let y = transformValue(shiftSize: cameraCenter.y, originalValue: object.position.y)
            let z = transformValue(shiftSize: cameraCenter.z, originalValue: object.position.z)

            // we flip the x and z because that's how the camera service expects it to be.
            object.position = Point3d(x: z, y: y, z: x)
        }

        let boxEuler = Point3d(x: euler.x, y: euler.y, z: euler.z)
        let box = Box(euler: boxEuler)

        return (objects,box)
    }

    func transformValue(shiftSize: Float, originalValue: Float)-> Float {
        return originalValue - shiftSize
    }
}

extension RoomMapController: ARSCNViewDelegate, ARSessionDelegate {

    func widthForHeight(_ height: CGFloat) -> CGFloat{
        return height * sin(30.0) / sin(60.0) / 2
    }


    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        if let name = anchor.name, name == "product_node" {
            print(name)
            let cylinder = SCNCylinder(radius: 0.1, height: 0.001)//SCNBox(width: 0.001, height: 0.001, length: 0.001, chamferRadius: 0.0)
            let transparentMaterial = SCNMaterial()
            transparentMaterial.lightingModel = .physicallyBased
            transparentMaterial.metalness.contents = 0.3
            transparentMaterial.roughness.contents = 1.0
            transparentMaterial.diffuse.contents = #imageLiteral(resourceName: "Image")
            transparentMaterial.transparency = 0.5
            transparentMaterial.isDoubleSided = true
            cylinder.firstMaterial? = transparentMaterial

            self.tempProductGeometry = cylinder
            let productNode = SCNNode(geometry: cylinder)
            productNode.name = "product_node_\(autoCounter)"
            productNode.eulerAngles = SCNVector3(-Float.pi / 2.0, 0.0, 0.0)
            node.addChildNode(productNode)
            return
        }
        if let _ = anchor as? ARPlaneAnchor {
            numberOfPlanesFound += 1
            print(numberOfPlanesFound)
        }

        if let objectAnchor = anchor as? ARObjectAnchor {

            guard let name = objectAnchor.referenceObject.name, name == "box" else { return }
            print("detected box")

            // create geometry
            let extent = objectAnchor.referenceObject.extent
            let cube = SCNBox(width: CGFloat(extent.x), height: CGFloat(extent.y), length: CGFloat(extent.z), chamferRadius: 0.0)

            // apply transparent material
            let material = SCNMaterial()
            material.transparency = 0.5
            cube.firstMaterial = material

            // add child node
            let detectionNode = SCNNode(geometry: cube)
            detectionNode.name = "BOX"
            node.addChildNode(detectionNode)

            // setup references
            self.detectionNode = detectionNode
            self.refNode = node
            self.refObject = objectAnchor.referenceObject
        }
    }

    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {

        case .notAvailable: 
            // show not available
            print("Not your lucky day...")
            break
        case .limited(let reason):
            // show limited
            switch reason {

            case .initializing:
                print("Look around")
                break
            case .excessiveMotion:
                print("Stop moving so much")
                break
            case .insufficientFeatures:
                print("I cant see anything")
                break
            case .relocalizing:
                print("Hold on I'm getting my sight back")
                break
            }
        case .normal:
            // all good
            print("All Good")
            break
        }
    }



    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        if currentStep == 3, trackDeviceForFrameState {
            self.thumbnailFrameState = isCameraFacingBox()
        }

        if let transform = sceneView.session.currentFrame?.camera.transform {

            let location = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            didCameraMove(to: location)
        }

        // check if node is in POV.
        guard let node = self.detectionNode else { return }

        if let pointOfView = sceneView.pointOfView {
            let visable = sceneView.isNode(node, insideFrustumOf: pointOfView)

            if objectVisable != visable {
                objectVisable = visable
            }
        }


    }



    func isCameraFacingBox() -> CameraFacingCheckResult {

        if povNode == nil {
            povNode = sceneView.pointOfView

            let cylinder = SCNCylinder(radius: 0.05, height: 0.001)
            let transparentMaterial = SCNMaterial()
            transparentMaterial.lightingModel = .physicallyBased
            transparentMaterial.metalness.contents = 0.3
            transparentMaterial.roughness.contents = 1.0
            transparentMaterial.diffuse.contents = #imageLiteral(resourceName: "Image")
            transparentMaterial.transparency = 0.5
            transparentMaterial.isDoubleSided = true
            cylinder.firstMaterial? = transparentMaterial

            self.tempProductGeometry = cylinder
            let povCamNode = SCNNode(geometry: cylinder)
            povCamNode.eulerAngles = SCNVector3(-Float.pi / 2.0, 0.0, 0.0)
            povCamNode.name = "POV"
            povNode?.addChildNode(povCamNode)
        }

        // get center point of device only if box was detected.
        guard let node = refNode else { return .boxNotDetectedYet}

        guard let frame = sceneView.session.currentFrame else { return .error }
        
        let cam = frame.camera



        let roll = cam.eulerAngles.x * 180 / .pi // value should be between -10 ~ +10
        let yaw = cam.eulerAngles.z * 180 / .pi // -174 ~ -179 || 0 ~ 5

        // check if we are in the correct rotation
        guard -10 ... 10 ~= roll && (-179 ... -174 ~= yaw || -5 ... 5 ~= yaw) else { return .invalidOrientation }


        guard objectVisable else { return .boxNotInCenter}





        // at this point we know that the box node is in the center of our screen.

        // create another hit test to see if the camera (phone) is parallel to the box
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -10.0
        let transform1 = simd.simd_mul(node.simdWorldTransform, translation)
        translation.columns.3.z = 10.0
        let transform2 = simd.simd_mul(node.simdWorldTransform, translation)


        let startLocation = SCNVector3(transform1.columns.3.x,
                                       transform1.columns.3.y + 0.2,
                                       transform1.columns.3.z)

        let endLocation = SCNVector3(transform2.columns.3.x,
                                     transform2.columns.3.y + 0.2,
                                     transform2.columns.3.z)


        let options: [String: Any] = [
            SCNHitTestOption.rootNode.rawValue : sceneView.scene.rootNode,
            SCNHitTestOption.ignoreChildNodes.rawValue : false,
            SCNHitTestOption.ignoreHiddenNodes.rawValue : false,
            SCNHitTestOption.backFaceCulling.rawValue : false,
            SCNHitTestOption.searchMode.rawValue : SCNHitTestSearchMode.all.rawValue,
            SCNHitTestOption.boundingBoxOnly.rawValue: true
        ]

        let hitRes = sceneView.scene.rootNode.hitTestWithSegment(from: startLocation,
                                                                 to: endLocation,
                                                                 options: options)
        for hit in hitRes {
            if hit.node.name == "POV" {
                var positionOnImage: [String : SCNVector3] = [:]
                self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                    if let name = node.name, self.trackedProducts.keys.contains(name) {
                        let pos = self.sceneView.projectPoint(node.presentation.worldPosition)
                        positionOnImage[name] = pos
                    }
                }

                var mappingWithId: [String: SCNVector3] = [:]
                for (k,v) in positionOnImage {
                    guard let product = trackedProducts[k] else { continue }
                    mappingWithId[product.id] = v
                }

                mappingWithId["CAM"] = self.sceneView.projectPoint(node.presentation.worldPosition)



                return .success(frame.capturedImage, mappingWithId, cam.imageResolution)
            }
        }
        return .notInFrontOfBox
    }

    /// Add pyarmids (FOV) to node based on AR Reference Object
    ///
    /// - Parameters:
    ///   - ref: The camrea reference object
    ///   - node: The node object.
    func renderCameraFOV(ref: ARReferenceObject, node: SCNNode) {
        let height: CGFloat = 1.0
        let width = widthForHeight(height)

        // create 2 pyramids with the same volume
        let pyramidHighLight = SCNPyramid(width: width, height: height, length: width)
        let pyramidGeo = SCNPyramid(width: width, height: height, length: width)

        // create material for the pyramid
        let transparentMaterial = SCNMaterial()
        transparentMaterial.lightingModel = .physicallyBased
        transparentMaterial.metalness.contents = 0.0
        transparentMaterial.roughness.contents = 1.0
        transparentMaterial.diffuse.contents = UIColor.blue
        transparentMaterial.transparency = 0.1


        // material for outlined pyramid
        let outlineMaterial = SCNMaterial()
        outlineMaterial.fillMode = .lines
        outlineMaterial.metalness.contents = 0.0
        outlineMaterial.roughness.contents = 1.0


        // apply material to pyramids
        pyramidHighLight.firstMaterial? = outlineMaterial
        pyramidHighLight.firstMaterial?.isDoubleSided = true
        pyramidGeo.firstMaterial? = transparentMaterial
        pyramidGeo.firstMaterial?.isDoubleSided = true

        let pyramidNode = SCNNode(geometry: pyramidGeo)
        let highlightNode = SCNNode(geometry: pyramidHighLight)


        let objWidth = ref.extent.z

        // set position to pyramid node to be the center of the detected object.
        pyramidNode.position = SCNVector3(ref.center.x,
                                          ref.center.y,
                                          ref.center.z
                                            + Float(pyramidGeo.height) + objWidth / 2.0)
        pyramidNode.eulerAngles = SCNVector3(-Float.pi / 2.0, 0.0, 0.0)

        highlightNode.position = pyramidNode.position
        highlightNode.eulerAngles = pyramidNode.eulerAngles


        // add nodes to given scene
        node.addChildNode(pyramidNode)
        node.addChildNode(highlightNode)
    }

}

extension RoomMapController: FlexibleSteppedProgressBarDelegate {
    public func progressBar(_ progressBar: FlexibleSteppedProgressBar, textAtIndex index: Int, position: FlexibleSteppedProgressBarTextLocation) -> String {
        switch position {
        case .bottom, .top:
            return ""
        case .center:
            return "\(index+1)"
        }
    }

    public func progressBar(_ progressBar: FlexibleSteppedProgressBar, canSelectItemAtIndex index: Int) -> Bool {
        return false
    }
}

extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }

    static func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z)
    }
}

extension UIColor {

    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    class var random: UIColor {
        return UIColor(rgb: Int(CGFloat(arc4random()) / CGFloat(UINT32_MAX) * 0xFFFFFF))
    }

}

extension RoomMapController: ProductSelectionControllerDelegate {
    public func didSelectProduct(_ controller: ProductSelectionController, product: Product) {


        guard let productNodeId = currentSelectedProductId,
            let trackableObject = trackedProducts[productNodeId],
            let id = product.id else { return }

        trackableObject.id = id

        currentSelectedProductId = nil
        controller.dismiss(animated: true, completion: nil)
    }

    public func didCancelSelection(_ controller: ProductSelectionController) {
        controller.dismiss(animated: true, completion: nil)

        currentSelectedProductId = nil
    }
}



extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        if let cgImage = cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }
}
