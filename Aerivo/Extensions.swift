//
//  Extensions.swift
//  Aerivo
//
//  Created by Harish Yerra on 7/22/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation
import UIKit
import ARKit

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

extension NSAttributedString {
    
    /// Concatenates two attributed strings together.
    ///
    /// - Parameters:
    ///   - left: The left hand attributed text.
    ///   - right: The right hand attributed text.
    /// - Returns: The combined attributed text.
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(lhs)
        result.append(rhs)
        return result
    }
}

extension NSMutableAttributedString {
    
    /// Highlights certain keywords in blue that are present within the string that are between a specified delimiter. Removes the specified delimiter after highlighting is complete.
    ///
    /// - Parameters:
    ///   - delimiter: A character that marks off what words should be highlighted. All words in between a pair of this delimiter will be highlighted.
    ///   - color: The color that should be used to highlight the text.
    func highlightKeywords(between delimiter: Character, with color: UIColor) {
        let asString = string
        
        guard let signUpRegex = try? NSRegularExpression(pattern:"\(delimiter)(.*?)\(delimiter)", options: []) else { return }
        
        var signUpRange: NSRange?
        signUpRegex.enumerateMatches(in: asString, options: [], range: NSRange(location: 0, length: asString.utf16.count)) { result, flags, stop in
            guard let range = result?.range(at: 1) else { return }
            signUpRange = range
        }
        
        guard let range = signUpRange else { return }
        addAttribute(.foregroundColor, value: color, range: range)
        mutableString.replaceOccurrences(of: "\(delimiter)", with: "", options: .literal, range: NSRange(location: 0, length: asString.utf16.count))
    }
}

// MARK: - float4x4 extensions

extension float4x4 {
    /**
     Treats matrix as a (right-hand column-major convention) transform matrix
     and factors out the translation component of the transform.
     */
    var translation: float3 {
        get {
            let translation = columns.3
            return float3(translation.x, translation.y, translation.z)
        }
        set(newValue) {
            columns.3 = float4(newValue.x, newValue.y, newValue.z, columns.3.w)
        }
    }
    
    /**
     Factors out the orientation component of the transform.
     */
    var orientation: simd_quatf {
        return simd_quaternion(self)
    }
    
    /**
     Creates a transform matrix with a uniform scale factor in all directions.
     */
    init(uniformScale scale: Float) {
        self = matrix_identity_float4x4
        columns.0.x = scale
        columns.1.y = scale
        columns.2.z = scale
    }
}

// MARK: - CGPoint extensions

extension CGPoint {
    /// Extracts the screen space point from a vector returned by SCNView.projectPoint(_:).
    init(_ vector: SCNVector3) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }
    
    /// Returns the length of a point when considered as a vector. (Used with gesture recognizers.)
    var length: CGFloat {
        return sqrt(x * x + y * y)
    }
}

extension UIView {
    /// Returns all of the subviews within a view including the subviews of subviews.
    var allSubviews: [UIView] {
        var subviewsArray = [subviews].flatMap { $0 }
        subviewsArray.forEach { subviewsArray.append(contentsOf: $0.allSubviews) }
        return subviewsArray
    }
}
