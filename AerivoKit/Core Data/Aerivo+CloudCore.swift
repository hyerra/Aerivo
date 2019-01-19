//
//  Aerivo+CloudCore.swift
//  AerivoKit
//
//  Created by Harish Yerra on 1/17/19.
//  Copyright © 2019 Harish Yerra. All rights reserved.
//

import CloudKit
import CloudCore

extension CloudCore {
    static func configureForAerivo() {
        CloudCore.config.container = CKContainer(identifier: "iCloud.com.harishyerra.Aerivo.shared")
        CloudCore.config.zoneName = "Aerivo"
        CloudCore.config.userDefaultsKeyTokens = "AerivoCloudKitTokens"
    }
}
