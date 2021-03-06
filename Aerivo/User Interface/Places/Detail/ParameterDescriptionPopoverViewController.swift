//
//  ParameterDescriptionPopoverViewController.swift
//  Aerivo
//
//  Created by Harish Yerra on 7/25/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit

class ParameterDescriptionPopoverViewController: UIViewController {
    
    static let identifier = "parameterDescriptionPopoverVC"
        
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var parameterDescription: UILabel!
    @IBOutlet weak var parameterDescriptionHeightConstraint: NSLayoutConstraint!
    
    var parameterInfo: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        parameterDescription.text = parameterInfo
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Do any additional setup after the view laid out the subviews.
        let spacingValue = UIFontMetrics(forTextStyle: .callout).scaledValue(for: 15)
        preferredContentSize = CGSize(width: parameterDescription.intrinsicContentSize.width + spacingValue, height: parameterDescription.intrinsicContentSize.height + spacingValue)
        parameterDescriptionHeightConstraint.constant = max(parameterDescription.intrinsicContentSize.height, scrollView.bounds.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
