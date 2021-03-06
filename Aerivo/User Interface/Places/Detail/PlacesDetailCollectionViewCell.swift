//
//  PlacesDetailCollectionViewCell.swift
//  Aerivo
//
//  Created by Harish Yerra on 7/23/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit

class PlacesDetailCollectionViewCell: UICollectionViewCell, UIPopoverPresentationControllerDelegate {
    
    static let reuseIdentifier = "placesDetailCell"
    
    @IBOutlet weak var detail: UIButton!
    
    var parameterDescription: String?
    weak var parameterDescriptionDelegate: ParameterDescriptionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        detail.contentEdgeInsets = UIEdgeInsets(top: .leastNormalMagnitude, left: .leastNormalMagnitude, bottom: .leastNormalMagnitude, right: .leastNormalMagnitude) /* Get rid of extra button padding. */
        detail.titleLabel?.adjustsFontForContentSizeCategory = true
        detail.accessibilityIgnoresInvertColors = true
        detail.titleLabel?.numberOfLines = 0
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
   }
    
    @IBAction func showParameterDescription(_ sender: UIButton) {
        guard let parameterDescription = parameterDescription else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let parameterDescriptionController = storyboard.instantiateViewController(withIdentifier: ParameterDescriptionPopoverViewController.identifier) as! ParameterDescriptionPopoverViewController
        parameterDescriptionController.modalPresentationStyle = .popover
        parameterDescriptionController.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        parameterDescriptionController.popoverPresentationController?.delegate = self
        parameterDescriptionController.popoverPresentationController?.sourceView = sender
        parameterDescriptionController.popoverPresentationController?.sourceRect = sender.bounds
        parameterDescriptionController.parameterInfo = parameterDescription
        parameterDescriptionDelegate?.show(parameterDescription: parameterDescriptionController)
    }
    
}
