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

public class RoomMapController: UIViewController {

    var sceneView: ARSCNView!

    var resetButton: GlassButton!

    var infoButton: GlassButton!

    var progressBar: FlexibleSteppedProgressBar!


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

    public override func loadView() {
        super.loadView()
        // init views
        sceneView = ARSCNView()
        resetButton = GlassButton()
        infoButton = GlassButton()
        progressBar = FlexibleSteppedProgressBar()

        self.view.addSubview(sceneView)
        self.view.addSubview(resetButton)
        self.view.addSubview(infoButton)
        self.view.addSubview(progressBar)


        // disable auto resizing mask
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false


        // auto layout
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 8.0),
            progressBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 8.0),
            progressBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -8.0),
            progressBar.heightAnchor.constraint(equalToConstant: 30.0),
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // more customizations
        sceneView.delegate = self

        progressBar.numberOfPoints = 6
        progressBar.lineHeight = 9
        progressBar.radius = 15
        progressBar.progressRadius = 20
        progressBar.progressLineHeight = 6

        progressBar.delegate = self

        progressBar.currentIndex = 3
        progressBar.viewBackgroundColor = #colorLiteral(red: 0.9401558042, green: 0.952983439, blue: 0.956292212, alpha: 1)
        progressBar.backgroundShapeColor = #colorLiteral(red: 0.9401558042, green: 0.952983439, blue: 0.956292212, alpha: 1)
        progressBar.centerLayerTextColor = .white

        progressBar.currentSelectedTextColor = .white
        progressBar.currentSelectedCenterColor = #colorLiteral(red: 0.1880986989, green: 0.8226090074, blue: 0.5176928043, alpha: 1)

        progressBar.selectedOuterCircleStrokeColor = .white
        progressBar.selectedBackgoundColor = #colorLiteral(red: 0.1880986989, green: 0.8226090074, blue: 0.5176928043, alpha: 1)
        progressBar.selectedOuterCircleLineWidth = 0.0

        progressBar.centerLayerTextColor = .white
        progressBar.centerLayerUnselectedTextColor = .gray



    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sceneView.session.run(sessionConfig)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        sceneView.session.pause()
    }
}

extension RoomMapController: ARSCNViewDelegate {

    func widthForHeight(_ height: CGFloat) -> CGFloat{
        return height * sin(30.0) / sin(60.0) / 2
    }

    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let objectAnchor = anchor as? ARObjectAnchor {


            let height: CGFloat = 1.0
            let width = widthForHeight(height)

            let pyramidHighLight = SCNPyramid(width: width, height: height, length: width)
            let pyramidGeo = SCNPyramid(width: width, height: height, length: width)

            let reflectiveMaterial = SCNMaterial()
            reflectiveMaterial.lightingModel = .physicallyBased
            reflectiveMaterial.metalness.contents = 0.0
            reflectiveMaterial.roughness.contents = 1.0
            reflectiveMaterial.diffuse.contents = UIColor.blue
            reflectiveMaterial.transparency = 0.1


            let outlineMaterial = SCNMaterial()
            outlineMaterial.fillMode = .lines
            outlineMaterial.metalness.contents = 0.0
            outlineMaterial.roughness.contents = 1.0


            pyramidHighLight.firstMaterial? = outlineMaterial

            pyramidGeo.firstMaterial? = reflectiveMaterial
            pyramidGeo.firstMaterial?.isDoubleSided = true

            guard let name = objectAnchor.referenceObject.name, name == "box" else { return }

            print("detected box")

            let pyramidNode = SCNNode(geometry: pyramidGeo)
            let highlightNode = SCNNode(geometry: pyramidHighLight)


            let objWidth = objectAnchor.referenceObject.extent.z

            // set position to pyramid node to be the center of the detected object.
            pyramidNode.position = SCNVector3(objectAnchor.referenceObject.center.x,
                                              objectAnchor.referenceObject.center.y,
                                              objectAnchor.referenceObject.center.z
                                                + Float(pyramidGeo.height) + objWidth / 2.0)

            pyramidNode.eulerAngles = SCNVector3(-Float.pi / 2.0, 0.0, 0.0)

            highlightNode.position = pyramidNode.position
            highlightNode.eulerAngles = pyramidNode.eulerAngles


            node.addChildNode(pyramidNode)
            node.addChildNode(highlightNode)
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
}

extension RoomMapController: ARSessionDelegate {
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        // new anchors detected
    }
}

extension RoomMapController: FlexibleSteppedProgressBarDelegate {
    public func progressBar(_ progressBar: FlexibleSteppedProgressBar, textAtIndex index: Int, position: FlexibleSteppedProgressBarTextLocation) -> String {
        switch position {
        case .bottom , .top:
            return ""
        case .center:
            return "\(index+1)"
        }
    }

    public func progressBar(_ progressBar: FlexibleSteppedProgressBar, canSelectItemAtIndex index: Int) -> Bool {
        return false
    }
}
