//
//  RoomMapController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 30/03/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit
import ARKit

public class RoomMapController: UIViewController {

    var sessionConfig: ARWorldTrackingConfiguration {
        let config = ARWorldTrackingConfiguration()
        config.isAutoFocusEnabled = true
        config.planeDetection = [.horizontal,.vertical]
        config.environmentTexturing = .automatic
        guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "the_box", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        config.detectionObjects = referenceObjects
        return config
    }

    var sceneView: ARSCNView!

    public override func loadView() {
        super.loadView()
        sceneView = ARSCNView()
        self.view.addSubview(sceneView)

        sceneView.translatesAutoresizingMaskIntoConstraints = false

        sceneView.delegate = self

        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

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

    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let objectAnchor = anchor as? ARObjectAnchor {
            let pyramid = SCNPyramid(width: 0.1, height: 0.2, length: 0.1)
            let reflectiveMaterial = SCNMaterial()
            reflectiveMaterial.lightingModel = .physicallyBased
            reflectiveMaterial.metalness.contents = 1.0
            reflectiveMaterial.roughness.contents = 0.2

            pyramid.firstMaterial? = reflectiveMaterial
            pyramid.firstMaterial?.isDoubleSided = true

            //
            guard let name = objectAnchor.referenceObject.name, name == "box" else { return }

            print("detected box")

            let pyramidNode = SCNNode(geometry: pyramid)

            let width = objectAnchor.referenceObject.extent.z

            // set position to pyramid node to be the center of the detected object.
            pyramidNode.position = SCNVector3(objectAnchor.referenceObject.center.x,
                                              objectAnchor.referenceObject.center.y,
                                              objectAnchor.referenceObject.center.z + Float(pyramid.height) + width / 2.0)

            pyramidNode.eulerAngles = SCNVector3(-Float.pi / 2.0, 0.0, 0.0)

            node.addChildNode(pyramidNode)
        }
    }
}

extension RoomMapController: ARSessionDelegate {
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        // new anchors detected
    }
}
