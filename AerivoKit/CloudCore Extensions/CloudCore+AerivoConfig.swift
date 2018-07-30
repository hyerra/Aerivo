//
//  CloudCore+AerivoConfig.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/30/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import CloudKit

extension CloudCoreConfig {
    /// The custom cloud core configuration for Aerivo.
    public static var aerivoConfig: CloudCoreConfig {
        var aerivoConfig = CloudCoreConfig()
        aerivoConfig.zoneID = CKRecordZoneID(zoneName: "Aerivo", ownerName: CKCurrentUserDefaultName)
        aerivoConfig.userDefaultsKeyTokens = "AerivoCloudKitTokens"
        return aerivoConfig
    }
}
