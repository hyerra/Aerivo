//
//  ARPlacesViewController.swift
//  Aerivo
//
//  Created by Harish Yerra on 8/4/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit
import ARKit
import CoreLocation
import MapboxSceneKit

class ARPlacesViewController: UIViewController {
    
    static let identifier = "arPlacesVC"
    
    @IBOutlet weak var sceneView: VirtualObjectARView!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var messagePanel: UIVisualEffectView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var addTerrainButton: UIButton!
    
    var location: CLLocationCoordinate2D!
    
    private weak var terrain: VirtualObject?
    private var planes: [UUID: SCNNode] = [UUID: SCNNode]()
    
    lazy var virtualObjectInteraction = VirtualObjectInteraction(sceneView: sceneView)
    
    var focusSquare = FocusSquare()
    
    let updateQueue = DispatchQueue(label: "com.harishyerra.Aerivo.serialSceneKitQueue")
    
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private let displayDuration: TimeInterval = 6
    private var messageHideTimer: Timer?
    private var timers: [MessageType: Timer] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        doneButton.titleLabel?.adjustsFontForContentSizeCategory = true
        
        // Set up scene content.
        setupCamera()
        sceneView.scene.rootNode.addChildNode(focusSquare)
        
        sceneView.setupDirectionalLighting(queue: updateQueue)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup right after the view appeared.
        UIApplication.shared.isIdleTimerDisabled = true
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Do any additional teardown right before the view will disappear.
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Camera
    
    func setupCamera() {
        guard let camera = sceneView.pointOfView?.camera else { return }
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }
    
    // MARK: - Session management
    
    /// Creates a new AR configuration to run on the `session`.
    func resetTracking() {
        virtualObjectInteraction.selectedObject = nil
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .planeEstimation)
    }
    
    // MARK: - Focus square
    
    func updateFocusSquare(isObjectVisible: Bool) {
        if isObjectVisible {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
            scheduleMessage(NSLocalizedString("TRY MOVING LEFT OR RIGHT", comment: "Tip for users when using AR to fix the issue."), inSeconds: 5.0, messageType: .focusSquare)
        }
        
        // Perform hit testing only when ARKit tracking is in a good state.
        if let camera = sceneView.session.currentFrame?.camera, case .normal = camera.trackingState,
            let result = self.sceneView.smartHitTest(screenCenter) {
            updateQueue.async {
                self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(hitTestResult: result, camera: camera)
            }
            addTerrainButton.isHidden = false
            cancelScheduledMessage(for: .focusSquare)
        } else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
            addTerrainButton.isHidden = true
        }
    }
    
    func displayErrorMessage(title: String, message: String) {
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func placeTerrain(_ sender: UIButton) {
        let tapPoint = screenCenter
        var result = sceneView.smartHitTest(tapPoint)
        if result == nil {
            result = sceneView.smartHitTest(tapPoint, infinitePlane: true)
        }
        
        guard result != nil, let anchor = result?.anchor, let plane = planes[anchor.identifier] else { return }
        
        insert(on: plane, from: result!)
        addTerrainButton.isHidden = true
    }
    
    private func insert(on plane: SCNNode, from hitResult: ARHitTestResult) {
        //Set up initial terrain and materials
        let terrainNode = VirtualObject(minLat: location.latitude - 0.1, maxLat: location.latitude + 0.1, minLon: location.longitude - 0.1, maxLon: location.longitude + 0.1)
        
        //Note: Again, you don't have to do this loading in-scene. If you know the area of the node to be fetched, you can
        //do this in the background while AR plane detection is still working so it is ready by the time
        //your user selects where to add the node in the world.
        
        //We're going to scale the node dynamically based on the size of the node and how far away the detected plane is
        let scale = Float(0.333 * hitResult.distance) / terrainNode.boundingSphere.radius
        terrainNode.transform = SCNMatrix4MakeScale(scale, scale, scale)
        terrainNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        terrainNode.geometry?.materials = defaultMaterials()
        sceneView.scene.rootNode.addChildNode(terrainNode)
        terrain = terrainNode
        
        terrainNode.fetchTerrainHeights(minWallHeight: 50.0, enableDynamicShadows: true, progress: { _, _ in }, completion: {
            NSLog("Terrain load complete")
        })
        
        terrainNode.fetchTerrainTexture("mapbox/satellite-v9", zoom: 14, progress: { _, _ in }, completion: { image in
            NSLog("Texture load complete")
            terrainNode.geometry?.materials[4].diffuse.contents = image
        })
        
    }
    
    private func defaultMaterials() -> [SCNMaterial] {
        let groundImage = SCNMaterial()
        groundImage.diffuse.contents = UIColor.darkGray
        groundImage.name = "Ground texture"
        
        let sideMaterial = SCNMaterial()
        sideMaterial.diffuse.contents = UIColor.darkGray
        //TODO: Some kind of bug with the normals for sides where not having them double-sided has them not show up
        sideMaterial.isDoubleSided = true
        sideMaterial.name = "Side"
        
        let bottomMaterial = SCNMaterial()
        bottomMaterial.diffuse.contents = UIColor.black
        bottomMaterial.name = "Bottom"
        
        return [sideMaterial, sideMaterial, sideMaterial, sideMaterial, groundImage, bottomMaterial]
    }
    
}

// MARK: - AR delegates

extension ARPlacesViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    // MARK: - AR scene view delegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        let isTerrainInView = terrain != nil ? sceneView.isNode(terrain!, insideFrustumOf: sceneView.pointOfView!) : false
        
        DispatchQueue.main.async {
            self.virtualObjectInteraction.updateObjectToCurrentTrackingPosition()
            self.updateFocusSquare(isObjectVisible: isTerrainInView)
        }
        
        // If light estimation is enabled, update the intensity of the directional lights
        if let lightEstimate = sceneView.session.currentFrame?.lightEstimate {
            sceneView.updateDirectionalLighting(intensity: lightEstimate.ambientIntensity, queue: updateQueue)
        } else {
            sceneView.updateDirectionalLighting(intensity: 1000, queue: updateQueue)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.cancelScheduledMessage(for: .planeEstimation)
            self.showMessage(NSLocalizedString("SURFACE DETECTED", comment: "Message for AR that says a surface has been detected."))
            if self.terrain == nil {
                self.scheduleMessage(NSLocalizedString("TAP + TO PLACE AN OBJECT", comment: "Message for AR that tells a user to place an object."), inSeconds: 7.5, messageType: .contentPlacement)
                self.addTerrainButton?.isHidden = false
            }
        }
        updateQueue.async {
            self.terrain?.adjustOntoPlaneAnchor(planeAnchor, using: node)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        updateQueue.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.terrain?.adjustOntoPlaneAnchor(planeAnchor, using: node)
            } else {
                if let terrain = self.terrain, terrain.anchor == anchor {
                    terrain.simdPosition = anchor.transform.translation
                    terrain.anchor = anchor
                }
            }
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
        
        switch camera.trackingState {
        case .notAvailable, .limited:
            escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
        case .normal:
            cancelScheduledMessage(for: .trackingStateEscalation)
            
            // Unhide content after successful relocalization.
            terrain?.isHidden = false
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Use `flatMap(_:)` to remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Hide content before going into the background.
        terrain?.isHidden = true
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        /*
         Allow the session to attempt to resume after an interruption.
         This process may not succeed, so the app must be prepared
         to reset the session if the relocalizing status continues
         for a long time -- see `escalateFeedback` in `StatusViewController`.
         */
        return true
    }
}


// MARK: - Status

extension ARPlacesViewController {
    
    // MARK: - Types
    
    enum MessageType: CaseIterable {
        case trackingStateEscalation
        case planeEstimation
        case contentPlacement
        case focusSquare
    }
    
    // MARK: - Message handling
    
    func showMessage(_ text: String, autoHide: Bool = true) {
        messageHideTimer?.invalidate()
        
        messageLabel.text = text
        
        // Make sure status is showing.
        setMessageHidden(false, animated: true)
        
        if autoHide {
            messageHideTimer = Timer.scheduledTimer(withTimeInterval: displayDuration, repeats: false, block: { [weak self] _ in
                self?.setMessageHidden(true, animated: true)
            })
        }
    }
    
    func scheduleMessage(_ text: String, inSeconds seconds: TimeInterval, messageType: MessageType) {
        cancelScheduledMessage(for: messageType)
        
        let timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { [weak self] timer in
            self?.showMessage(text)
            timer.invalidate()
        })
        
        timers[messageType] = timer
    }
    
    func cancelScheduledMessage(for messageType: MessageType) {
        timers[messageType]?.invalidate()
        timers[messageType] = nil
    }
    
    func cancelAllScheduledMessages() {
        for messageType in MessageType.allCases {
            cancelScheduledMessage(for: messageType)
        }
    }
    
    // MARK: - ARKit
    
    func showTrackingQualityInfo(for trackingState: ARCamera.TrackingState, autoHide: Bool) {
        showMessage(trackingState.presentationString, autoHide: autoHide)
    }
    
    func escalateFeedback(for trackingState: ARCamera.TrackingState, inSeconds seconds: TimeInterval) {
        cancelScheduledMessage(for: .trackingStateEscalation)
        
        let timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { [unowned self] _ in
            self.cancelScheduledMessage(for: .trackingStateEscalation)
            
            var message = trackingState.presentationString
            if let recommendation = trackingState.recommendation {
                message.append(": \(recommendation)")
            }
            
            self.showMessage(message, autoHide: false)
        })
        
        timers[.trackingStateEscalation] = timer
    }
    
    // MARK: - Panel visibility
    
    private func setMessageHidden(_ hide: Bool, animated: Bool) {
        // The panel starts out hidden, so show it before animating opacity.
        messagePanel.isHidden = false
        
        guard animated else {
            messagePanel.alpha = hide ? 0 : 1
            return
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
            self.messagePanel.alpha = hide ? 0 : 1
        }, completion: nil)
    }
}

extension ARCamera.TrackingState {
    var presentationString: String {
        switch self {
        case .notAvailable:
            return NSLocalizedString("TRACKING UNAVAILABLE", comment: "Error message when AR can't track surfaces and objects.")
        case .normal:
            return NSLocalizedString("TRACKING NORMAL", comment: "Success message for AR when we can track surfaces and objects.")
        case .limited(.excessiveMotion):
            return NSLocalizedString("TRACKING LIMITED\nExcessive motion", comment: "Warning message for AR when there is limited tracking due to excessive motion.")
        case .limited(.insufficientFeatures):
            return NSLocalizedString("TRACKING LIMITED\nLow detail", comment: "Warning message for AR when there is limited tracking due to insufficient features.")
        case .limited(.initializing):
            return NSLocalizedString("Initializing", comment: "Message for AR when it is being initialized.")
        case .limited(.relocalizing):
            return NSLocalizedString("Relocalizing", comment: "Message for AR when it is recovering from an interruption.")
        }
    }
    
    var recommendation: String? {
        switch self {
        case .limited(.excessiveMotion):
            return NSLocalizedString("Try slowing down your movement.", comment: "Recommendation to get out of a warning from AR.")
        case .limited(.insufficientFeatures):
            return NSLocalizedString("Try pointing at a flat surface, or reset the session.", comment: "Recommendation to get out of a warning from AR.")
        case .limited(.relocalizing):
            return NSLocalizedString("Return to the location where you left off or try resetting the session.", comment: "Recommendation to get out of a warning from AR.")
        default:
            return nil
        }
    }
}
