//
//  PlacesTableViewCell.swift
//  Aerivo
//
//  Created by Harish Yerra on 7/8/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit
import AerivoKit
import MapboxGeocoder

class PlacesTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "placesCell"
    
    var placemark: GeocodedPlacemark!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var secondaryDetail: UILabel!
    
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    @IBOutlet var iconSpacingConstraints: [NSLayoutConstraint]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Modify layout
        iconBackgroundView.layer.cornerRadius = iconBackgroundView.bounds.height / 2
        iconBackgroundView.layer.masksToBounds = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Do any layout related work when the interface environment changes.
        iconWidthConstraint.constant = UIFontMetrics.default.scaledValue(for: 20)
        iconSpacingConstraints.forEach { $0.constant = UIFontMetrics.default.scaledValue(for: 6) }
        stackView.axis = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? .vertical : .horizontal
        stackView.alignment = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? .top : .center
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
