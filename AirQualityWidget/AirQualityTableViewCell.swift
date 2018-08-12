//
//  AirQualityTableViewCell.swift
//  AirQualityWidget
//
//  Created by Harish Yerra on 8/12/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit

class AirQualityTableViewCell: UITableViewCell {
    
    static let identifier = "airQualityCell"
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var parameter: UILabel!
    @IBOutlet weak var valueView: UIView!
    @IBOutlet weak var value: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Do any layout related work when the interface environment changes.
        let cornerRadius = UIFontMetrics(forTextStyle: .caption1).scaledValue(for: 3)
        valueView.layer.cornerRadius = cornerRadius
        valueView.layer.masksToBounds = true
        
        stackView.axis = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? .vertical : .horizontal
        stackView.alignment = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? .top : .center
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
