//
//  PlacesDetailViewController.swift
//  Aerivo
//
//  Created by Harish Yerra on 7/20/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit
import AerivoKit

class PlacesDetailViewController: UIViewController {
    
    static let identifier = "placesDetailVC"
    
    var placemark: GeocodedPlacemark!
    let blurEffect = UIBlurEffect(style: .extraLight)
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var close: UIButton!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var topGripperView: UIView!
    @IBOutlet weak var bottomGripperView: UIView!
    
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var address: UILabel!
    
    var headerHeightConstraint: NSLayoutConstraint?
    
    lazy var cachedHeaderHeight: CGFloat = {
        let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        return height
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        placeName.text = placemark.formattedName
        detail.text = placemark.genres?.first ?? placemark.address ?? ""
        address.text = placemark.qualifiedName
        
        if let pulleyVC = presentingViewController?.pulleyViewController { drawerDisplayModeDidChange(drawer: pulleyVC) }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Do any additional setup after the view laid out the subviews.
        createViewBlurEffect()
        sizeHeaderToFit()
        
        close.layer.cornerRadius = close.layer.bounds.width/2
        close.layer.masksToBounds = true
    }
    
    private func createViewBlurEffect() {
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        blurEffectView.frame = view.bounds
        vibrancyEffectView.frame = blurEffectView.bounds
        view.insertSubview(blurEffectView, at: 0)
    }
    
    private func sizeHeaderToFit() {
        if let constraint = headerHeightConstraint { NSLayoutConstraint.deactivate([constraint]) }
        let newConstraint = headerView.heightAnchor.constraint(equalToConstant: cachedHeaderHeight)
        newConstraint.isActive = true
        headerHeightConstraint = newConstraint
    }
    
}

// MARK: - Pulley drawer delegate

extension PlacesDetailViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return cachedHeaderHeight + bottomSafeArea
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 264 + bottomSafeArea
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        loadViewIfNeeded()
        
        if drawer.drawerPosition == .collapsed {
            if let constraint = headerHeightConstraint { NSLayoutConstraint.deactivate([constraint]) }
            let newConstraint = headerView.heightAnchor.constraint(equalToConstant: cachedHeaderHeight + bottomSafeArea)
            newConstraint.isActive = true
            headerHeightConstraint = newConstraint
        } else {
            if let constraint = headerHeightConstraint { NSLayoutConstraint.deactivate([constraint]) }
            let newConstraint = headerView.heightAnchor.constraint(equalToConstant: cachedHeaderHeight)
            newConstraint.isActive = true
            headerHeightConstraint = newConstraint
        }
        
    }
    
    func drawerDisplayModeDidChange(drawer: PulleyViewController) {
        if drawer.currentDisplayMode == .bottomDrawer {
            topGripperView.alpha = 1
            bottomGripperView.alpha = 0
        } else {
            topGripperView.alpha = 0
            bottomGripperView.alpha = 1
        }
    }
}
