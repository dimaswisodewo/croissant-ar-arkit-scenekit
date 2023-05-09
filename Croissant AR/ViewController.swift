//
//  ViewController.swift
//  Croissant AR
//
//  Created by Dimas Wisodewo on 09/05/23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // Array to store all placed assets on the scene
    var placedAssets: [SCNNode] = []
    
    let clearButton : UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 80/255, green: 101/255, blue: 161/255, alpha: 1)
        button.layer.cornerRadius = 20
        button.layer.cornerCurve = .continuous
        button.setTitle("Clear", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show feature points tracked by ARKit
        // sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Add default lighting
        sceneView.autoenablesDefaultLighting = true
        
        // Add clear button to view
        view.addSubview(clearButton)
        
        setupClearButton()
    }
    
    // On clear button pressed
    func setupClearButton() {
        
        let insets = view.safeAreaInsets
        clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        clearButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom).isActive = true
        clearButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        clearButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Add event to the clear button
        clearButton.addTarget(self, action: #selector(clearScene), for: .touchUpInside)
    }
    
    // Remove placed assets
    @objc func clearScene() {
        
        if !placedAssets.isEmpty {
            for node in placedAssets {
                node.removeFromParentNode()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Set horizontal plane detection
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            // Get touch location
            let touchLocation = touch.location(in: sceneView)
            
            // Creates a raycast query that originates from a point on the view, aligned with the center of the camera's field of view
            guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .horizontal) else {
                print("Raycast query failed")
                return
            }
                    
            // Checks once for intersections between a ray and real-world surfaces.
            let raycastResults = sceneView.session.raycast(query)
            guard let hitTestResult = raycastResults.first else {
               print("No surface found")
               return
            }
            
            // Load croissant scene
            let scene = SCNScene(named: "art.scnassets/croissant.scn")!
            
            // Searches the children of the receiving node for a node with a specific name
            if let node = scene.rootNode.childNode(withName: "croissant", recursively: true) {
                
                // Set node position based on the tapped surface
                node.position = SCNVector3(
                    x: hitTestResult.worldTransform.columns.3.x,
                    y: hitTestResult.worldTransform.columns.3.y,
                    z: hitTestResult.worldTransform.columns.3.z
                )
                
                // Randomize node rotation on y axis
                let yRotation = Float.random(in: 0...360)
                node.eulerAngles = SCNVector3(x: 0, y: yRotation, z: 0)
                
                // Add node
                sceneView.scene.rootNode.addChildNode(node)
                
                // Add node into array
                placedAssets.append(node)
            } else {
                print("Spawn node failed")
            }
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
