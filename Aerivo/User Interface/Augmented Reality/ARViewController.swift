//
//  ARViewController.swift
//  Aerivo
//
//  Created by Harish Yerra on 8/4/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit

class ARViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup right after the view appeared.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Do any additional teardown right before the view will disappear.
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
