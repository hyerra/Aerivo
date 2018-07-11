//
//  PlacesTableViewCell.swift
//  Aerivo
//
//  Created by Harish Yerra on 7/8/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit

class PlacesTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "placesCell"
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var secondaryDetail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Modify layout
        iconBackgroundView.layer.cornerRadius = iconBackgroundView.bounds.height/2
        iconBackgroundView.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
