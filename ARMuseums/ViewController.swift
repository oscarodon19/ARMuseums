//
//  ViewController.swift
//  ARMuseums
//
//  Created by Oscar Odon on 29/02/2020.
//  Copyright © 2020 Oscar Odon. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var paitings = [String:Paiting]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        self.loadPaitingData()
        
        self.preloadWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARImageTrackingConfiguration()
        guard let trankingImages = ARReferenceImage.referenceImages(inGroupNamed: "Paintings", bundle: nil) else {
            fatalError("No se han podido cargar las imagenes de AR")
        }
        configuration.trackingImages = trankingImages
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let imageAnchor = anchor as? ARImageAnchor else { return nil }
        guard let paintingName = imageAnchor.referenceImage.name else { return nil }
        guard let paiting = paitings[paintingName] else { return nil }
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi/2
        
        
        let node = SCNNode()
        node.opacity = 0
        node.addChildNode(planeNode)
        
        
        
        return node
    }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    //MARK: Manage data
    func loadPaitingData() {
        guard let url = Bundle.main.url(forResource: "paitings", withExtension: "json") else {
            fatalError("No hemos podido conseguir la información de los datos")
        }
        
        guard let jsonData = try? Data(contentsOf: url) else {
            fatalError("No se ha podido leer la información del JSON")
        }
        
        let jsonDecoder = JSONDecoder()
        guard let decodedPaitings = try? jsonDecoder.decode([String:Paiting].self, from: jsonData) else {
            fatalError("Problemas al procesar el archivo JSON")
        }
        
        self.paitings = decodedPaitings
    }
    
    func preloadWebView() {
        let preload = UIWebView()
        self.view.addSubview(preload)
        let request = URLRequest(url: URL(string: "https://es.wikipedia.org/wiki/La_balsa_de_la_Medusa")!)
        preload.loadRequest(request)
        preload.removeFromSuperview()
    }
}
