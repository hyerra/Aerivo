//
//  MGPlacemarkScope+Color.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/12/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit

extension MBPlacemarkScope {
    public var displayColor: UIColor {
        switch self {
        case .country: return #colorLiteral(red: 0.9843137255, green: 0.3960784314, blue: 0.2588235294, alpha: 1)
        case .region: return #colorLiteral(red: 0.2980392157, green: 0.7098039216, blue: 0.9607843137, alpha: 1)
        case .district: return #colorLiteral(red: 0.9803921569, green: 0.4039215686, blue: 0.4588235294, alpha: 1)
        case .postalCode: return #colorLiteral(red: 0.8823529412, green: 0.1921568627, blue: 0.3568627451, alpha: 1)
        case .place: return #colorLiteral(red: 0.2, green: 0.737254902, blue: 0.6274509804, alpha: 1)
        case .locality: return #colorLiteral(red: 0.5921568627, green: 0.5725490196, blue: 0.8901960784, alpha: 1)
        case .neighborhood: return #colorLiteral(red: 1, green: 0.7137254902, blue: 0.1725490196, alpha: 1)
        case .address: return #colorLiteral(red: 0.9803921569, green: 0.4039215686, blue: 0.4588235294, alpha: 1)
        case .landmark: return #colorLiteral(red: 0.9843137255, green: 0.3960784314, blue: 0.2588235294, alpha: 1)
        case .pointOfInterest: return #colorLiteral(red: 0.5921568627, green: 0.5725490196, blue: 0.8901960784, alpha: 1)
        case .all: return #colorLiteral(red: 1, green: 0.7137254902, blue: 0.1725490196, alpha: 1)
        default: return #colorLiteral(red: 0.9843137255, green: 0.3960784314, blue: 0.2588235294, alpha: 1)
        }
    }
}
