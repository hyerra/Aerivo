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
    
    @IBOutlet weak var plusPanel: UIVisualEffectView!
    
    var location: CLLocationCoordinate2D!
    
    private var terrain: VirtualObject?
    var isTerrainVisible: Bool {
        if let terrain = terrain {
            return sceneView.scene.rootNode.childNodes.contains(terrain)
        }
        return false
    }
    
    var isRestartAvailable = true
    
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
    
    @IBOutlet weak var addTerrainBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        doneButton.titleLabel?.adjustsFontForContentSizeCategory = true
        
        // Set up scene content.
        setupCamera()
        sceneView.scene.rootNode.addChildNode(focusSquare)
        
        loadTerrain()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup right before the view will appear.
        presentingViewController?.presentingViewController?.pulleyViewController?.setNeedsSupportedDrawerPositionsUpdate()
        resetTracking()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Do any additional setup after the view laid out the subviews.
        if let pulleyVC = presentingViewController?.presentingViewController?.pulleyViewController {
            switch pulleyVC.currentDisplayMode {
            case .bottomDrawer:
                addTerrainBottomConstraint.constant = pulleyVC.bounceOverflowMargin + 15
            case .leftSide:
                addTerrainBottomConstraint.constant = 15
            case .automatic:
                addTerrainBottomConstraint.constant = 15
            }
        } else {
            addTerrainBottomConstraint.constant = 15
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup right after the view appeared.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Do any additional teardown right before the view will disappear.
        sceneView.session.pause()
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
        camera.wantsExposureAdaptation = true
    }
    
    // MARK: - Terrain loading
    
    private func loadTerrain() {
        //Set up initial terrain and materials
        let terrainNode = TerrainNode(minLat: location.latitude - 0.0075, maxLat: location.latitude + 0.0075, minLon: location.longitude - 0.0075, maxLon: location.longitude + 0.0075)
        
        terrainNode.transform = SCNMatrix4MakeScale(0.0002, 0.0002, 0.0002)
        terrainNode.geometry?.materials = defaultMaterials()
        
        self.terrain = VirtualObject(node: terrainNode)
        
        terrainNode.fetchTerrainHeights(minWallHeight: 50.0, enableDynamicShadows: true, progress: { _, _ in }) { }
        terrainNode.fetchTerrainTexture("mapbox/satellite-v9", zoom: 14, progress: { _, _ in }, completion: { image in
            terrainNode.geometry?.materials[4].diffuse.contents = image
        })
    }
    
    // MARK: - Session management
    
    /// Creates a new AR configuration to run on the `session`.
    func resetTracking() {
        virtualObjectInteraction.selectedObject = nil
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        scheduleMessage(NSLocalizedString("FIND A SURFACE TO PLACE AN OBJECT", comment: "Tells the user to find a surface so they can place an object in AR."), inSeconds: 7.5, messageType: .planeEstimation)
        plusPanel.isHidden = false
    }
    
    func restartExperience() {
        guard isRestartAvailable else { return }
        isRestartAvailable = false
        
        cancelAllScheduledMessages()
        
        terrain?.removeFromParentNode()
        
        resetTracking()
        
        // Disable restart for a while in order to give the session time to restart.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
        }
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
            cancelScheduledMessage(for: .focusSquare)
        } else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func placeTerrain(_ sender: UIButton) {
        guard let terrain = terrain else { return }
        self.isRestartAvailable = false
        self.sceneView.prepare([terrain], completionHandler: { _ in
            DispatchQueue.main.async {
                self.isRestartAvailable = true
                self.place(virtualObject: terrain)
            }
        })
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        let pulleyVC = presentingViewController?.presentingViewController?.pulleyViewController
        dismiss(animated: true) {
            pulleyVC?.setNeedsSupportedDrawerPositionsUpdate()
        }
    }
    
    @IBAction func refresh(_ sender: UIButton) {
        restartExperience()
    }
    
    func place(virtualObject: VirtualObject) {
        guard focusSquare.state != .initializing else {
            showMessage(NSLocalizedString("CANNOT PLACE OBJECT\nTry moving left or right.", comment: "AR message telling the user that they cannot place the object now and they must move left or right first."))
            return
        }
        
        virtualObjectInteraction.translate(virtualObject, basedOn: screenCenter, infinitePlane: false, allowAnimation: false)
        virtualObjectInteraction.selectedObject = virtualObject
        
        updateQueue.async {
            self.sceneView.scene.rootNode.addChildNode(virtualObject)
            self.sceneView.addOrUpdateAnchor(for: virtualObject)
            self.cancelScheduledMessage(for: .contentPlacement)
        }
        
        plusPanel.isHidden = true
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
    
}

// MARK: - AR delegates

extension ARPlacesViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    // MARK: - AR scene view delegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.virtualObjectInteraction.updateObjectToCurrentTrackingPosition()
            self.updateFocusSquare(isObjectVisible: self.isTerrainVisible)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.cancelScheduledMessage(for: .planeEstimation)
            if !self.isTerrainVisible {
                self.showMessage(NSLocalizedString("SURFACE DETECTED", comment: "Message for AR that says a surface has been detected."))
                self.scheduleMessage(NSLocalizedString("TAP + TO PLACE AN OBJECT", comment: "Message for AR that tells a user to place an object."), inSeconds: 7.5, messageType: .contentPlacement)
                self.plusPanel.isHidden = false
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
            self.displayErrorMessage(title: NSLocalizedString("AR Failed", comment: "The title for the error saying that there was an issue with AR."), message: errorMessage)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Hide content before going into the background.
        terrain?.isHidden = true
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
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
        
        let timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { [weak self] _ in
            self?.cancelScheduledMessage(for: .trackingStateEscalation)
            
            var message = trackingState.presentationString
            if let recommendation = trackingState.recommendation {
                message = String.localizedStringWithFormat("%@: %@", message, recommendation)
            }
            
            self?.showMessage(message, autoHide: false)
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
