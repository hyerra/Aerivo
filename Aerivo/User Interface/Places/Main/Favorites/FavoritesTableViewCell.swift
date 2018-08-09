//
//  FavoritesTableViewCell.swift
//  Aerivo
//
//  Created by Harish Yerra on 8/3/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "favoritesCell"
    
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    @IBOutlet var iconSpacingConstraints: [NSLayoutConstraint]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        shouldGroupAccessibilityChildren = true
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
