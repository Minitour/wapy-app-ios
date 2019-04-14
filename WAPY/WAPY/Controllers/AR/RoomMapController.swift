//
//  RoomMapController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 30/03/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit
import ARKit
import FlexibleSteppedProgressBar
import PKHUD

enum CalibrationPhase: Int {
    case plane
    case camera
    case product
    case window
    case overview
}

public class RoomMapController: UIViewController {

    public override var prefersStatusBarHidden: Bool {
        return true
    }

    var taskManager: TaskManager = TaskManager()

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

    // MARK: - State

    /// The current step. Variable is changed from background threads.
    var currentStep: Int = 0 {
        didSet{
            // did step change
            if currentStep == 2 {
                DispatchQueue.main.async {
                   self.nextButton.isHidden = false
                }
            }
        }
    }

    var numberOfPlanesFound: Int = 0 {
        didSet{
            if currentStep == 0 {
                onDataChanged()
            }
        }
    }

    var cameraDetected: Bool = false

    var numberOfProducts: Int = 0

    // MARK: - Tracked variables

    // the start location
    var startLocation: SCNVector3?

    var tempProductGeometry: SCNCylinder?

    /// The camera object that was detected.
    var refObject: ARReferenceObject?

    /// The reference node for the detected object.
    var refNode: SCNNode?

    /// reference use to check if the box is in the POV of the camera.
    var detectionNode: SCNNode?

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

    let padding: CGFloat = 16.0
    let buttonHeight: CGFloat = 55.0
    let progressBarHeight: CGFloat = 40.0

    public override func loadView() {
        super.loadView()
        // init views
        sceneView = ARSCNView()
        resetButton = GlassButton()
        infoButton = GlassButton()
        progressBar = FlexibleSteppedProgressBar()
        nextButton = .systemButton(withTitle: "Next")
        messageLabel = PaddingLabel()


        self.view.addSubview(sceneView)
        self.view.addSubview(resetButton)
        self.view.addSubview(infoButton)
        self.view.addSubview(progressBar)
        self.view.addSubview(nextButton)
        self.view.addSubview(messageLabel)


        // disable auto resizing mask
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

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
            messageLabel.bottomAnchor.constraint(equalTo: nextButton.topAnchor,constant: -padding)
        ])

        // more customizations
        sceneView.delegate = self

        progressBar.delegate = self
        progressBar.numberOfPoints = 6
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

    }

    public override func viewDidLoad() {
        super.viewDidLoad()
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

    }

    @objc func didSelectInfo(_ sender: UIButton) {

    }

    @objc func didSelectNext(_ sender: UIButton) {
        onDataChanged()
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
        let location = SCNVector3(pos.columns.3.x, pos.columns.3.y, pos.columns.3.z)

        // on touch begun
        if sender.state == .began {
            if currentStep == 2 {
                startLocation = location

                var translation = matrix_identity_float4x4
                translation.columns.3.z = -0.05
                let transform = simd.simd_mul(pos, translation)

                // add anchor to scene
                let tempAnchor = ARAnchor(name: "product_node", transform: transform)
                sceneView.session.add(anchor: tempAnchor)
            }
        }

        // on touch end
        if sender.state == .ended {

            if currentStep == 2 {
                if let startLocaiton = self.startLocation {
                    let radius = (startLocaiton - location).length()
                    let obj = TrackableObject(id: UUID().uuidString,
                                    r: radius,
                                    position: Point3d(x: startLocaiton.x, y: startLocaiton.y, z: startLocaiton.z))
                    print(obj.dictionary)
                    numberOfProducts += 1

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
            completion = Float(self.numberOfPlanesFound) / 10
        }

        // step 1 is the step in which we detect the camera object.
        if self.currentStep == 1 {
            completion = objectVisable ? 1.0 : 0.0

            if objectVisable {
                if let referenceObject = self.refObject,
                    let node = self.refNode {
                    // add pyramid and stuff
                    renderCameraFOV(ref: referenceObject, node: node)

                    // set to nil to avoid adding the object twice.
                    self.refObject = nil
                }
            }
        }

        // step 2 is the step in which we add objects
        if self.currentStep == 2 {
            // evaluation logic
            completion = numberOfProducts > 3 ? 1.0 : 0.0
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
                self.progressBar.currentIndex += 1
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
}

extension RoomMapController: ARSCNViewDelegate, ARSessionDelegate {

    func widthForHeight(_ height: CGFloat) -> CGFloat{
        return height * sin(30.0) / sin(60.0) / 2
    }


    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        if let name = anchor.name, name == "product_node" {
            print("product_node")
            let cylinder = SCNCylinder(radius: 0.1, height: 0.001)//SCNBox(width: 0.001, height: 0.001, length: 0.001, chamferRadius: 0.0)
            let transparentMaterial = SCNMaterial()
            transparentMaterial.lightingModel = .physicallyBased
            transparentMaterial.metalness.contents = 0.3
            transparentMaterial.roughness.contents = 1.0
            transparentMaterial.diffuse.contents = UIColor.random
            transparentMaterial.transparency = 0.5

            cylinder.firstMaterial? = transparentMaterial
            cylinder.firstMaterial?.isDoubleSided = true


            self.tempProductGeometry = cylinder
            let productNode = SCNNode(geometry: cylinder)
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
            material.transparency = 0.0
            cube.firstMaterial = material

            // add child node
            let detectionNode = SCNNode(geometry: cube)
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
