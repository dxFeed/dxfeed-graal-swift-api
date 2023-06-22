//
//  ARQuoteTableViewController.swift
//  DxFeedSampleApp
//
//  Created by Aleksey Kosylo on 21.06.23.
//

import Foundation
import UIKit
import ARKit

class ARQuoteTableViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var statusLabel: UILabel!

    var quotesViewController: UIViewController
    let configuration = ARWorldTrackingConfiguration()
    var grids = [Any]()
    var holderNode: SCNNode?

    required init?(coder: NSCoder) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        quotesViewController = storyboard.instantiateViewController(withIdentifier: "QuoteTableViewController")
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))

        // Add recognizer to sceneview
        sceneView.addGestureRecognizer(tap)
    }

    @objc func handleTap(rec: UITapGestureRecognizer) {
        if rec.state == .ended {
            //            createUIViewOnNode(result: nil)

            let tapLocation: CGPoint = rec.location(in: sceneView)
            let estimatedPlane: ARRaycastQuery.Target = .estimatedPlane
            let alignment: ARRaycastQuery.TargetAlignment = .horizontal

            let query: ARRaycastQuery? = sceneView.raycastQuery(from: tapLocation,
                                                                allowing: estimatedPlane,
                                                                alignment: alignment)

            if let nonOptQuery: ARRaycastQuery = query {

                let result: [ARRaycastResult] = sceneView.session.raycast(nonOptQuery)

                guard let rayCast: ARRaycastResult = result.first
                else { return }
                print(rayCast)

                createUIViewOnNode(result: rayCast)
            }

        }
    }
    func loadQuotes() {

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        quotesViewController.loadViewIfNeeded()
        if let quotesViewController = quotesViewController as? QuoteTableViewController {
            quotesViewController.subscribe()
        }

        // Create a session configuration

        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }

    func createUIViewOnNode(result: ARRaycastResult?) {
        guard let result = result else {
            return
        }
        if holderNode == nil {
            holderNode = SCNNode()
            let billboardConstraint = SCNBillboardConstraint()
            billboardConstraint.freeAxes = [.X, .Y, .Z]
            holderNode?.constraints = [billboardConstraint]
            let width = 0.15
            holderNode?.geometry = SCNPlane(width: width,
                                            height: width /
                                            (quotesViewController.view.frame.size.width / quotesViewController.view.frame.size.height))

            let material = SCNMaterial()

            let viewToAdd = quotesViewController.view
            viewToAdd?.backgroundColor = .background

            material.diffuse.contents = viewToAdd

            holderNode?.geometry?.firstMaterial = material
            material.isDoubleSided = true

            sceneView.scene.rootNode.addChildNode(holderNode!)
        }
        holderNode?.position = SCNVector3(result.worldTransform.columns.3.x,
                                          result.worldTransform.columns.3.y,
                                          result.worldTransform.columns.3.z)
    }

}

extension ARQuoteTableViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer,
                  didAdd node: SCNNode,
                  for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {
            return
        }
        DispatchQueue.main.async {
            self.statusLabel.alpha = 0
            self.statusLabel.text = "Ready"
            UIView.animate(withDuration: 0.5) {
                self.statusLabel.alpha = 1
            } completion: { _ in
                UIView.animate(withDuration: 0.5) {
                    self.statusLabel.alpha = 0
                }
            }
        }
    }
}
