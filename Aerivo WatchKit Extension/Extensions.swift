//
//  Extensions.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/19/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit

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
