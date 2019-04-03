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
}

extension RoomMapController: ARSessionDelegate {
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        // new anchors detected
    }
}
