//
//  AOAnnotationView.swift
//  Aerivo
//
//  Created by Harish Yerra on 7/11/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Mapbox
import UIKit

class AOAnnotationView: MGLAnnotationView {
    
    static let reuseIdentifier = "defaultAnnotation"
    
    var annotationImage = UIImageView()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // Draw the view's content here.
        annotationImage.contentMode = .scaleAspectFit
        annotationImage.tintColor = .white
        annotationImage.adjustsImageSizeForAccessibilityContentSizeCategory = true
        addSubview(annotationImage)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Adjust layout as needed.
        let innerSpacing: CGFloat = 15
        annotationImage.frame = CGRect(x: innerSpacing/2, y: innerSpacing/2, width: bounds.width - innerSpacing, height: bounds.height - innerSpacing)
        layer.cornerRadius = bounds.width/2
        layer.masksToBounds = true
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
        // Do any cleanup before reusing the view.
        annotationImage.image = nil
    }
}
