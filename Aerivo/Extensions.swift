//
//  Extensions.swift
//  Aerivo
//
//  Created by Harish Yerra on 7/22/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    /// Lightens a specified color by a certain percentage.
    ///
    /// - Parameter percentage: The percentage the color should be lightened by.
    /// - Returns: The lightened color.
    func lightened(by percentage: CGFloat) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    /// Darkens a specified color by a certain percentage.
    ///
    /// - Parameter percentage: The percentage the color should be darkened by.
    /// - Returns: The darkened color.
    func darkened(by percentage: CGFloat) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    /// Adjusts the color by a certain percentage.
    ///
    /// - Parameter percentage: The percentage the color should be adjusted by.
    /// - Returns: The adjusted color.
    func adjust(by percentage: CGFloat) -> UIColor? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return UIColor(red: min(r + percentage/100, 1.0), green: min(g + percentage/100, 1.0), blue: min(b + percentage/100, 1.0), alpha: a)
    }
}
