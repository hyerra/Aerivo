//
//  CloudCore+AerivoConfig.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/30/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import CloudKit
import CloudCore

extension CloudCoreConfig {
    /// The custom cloud core configuration for Aerivo.
    public static var aerivoSharedConfig: CloudCoreConfig {
        var aerivoSharedConfig = CloudCoreConfig()
        aerivoSharedConfig.container = CKContainer(identifier: "iCloud.com.harishyerra.Aerivo.shared")
        aerivoSharedConfig.zoneID = CKRecordZone.ID(zoneName: "Aerivo", ownerName: CKCurrentUserDefaultName)
        aerivoSharedConfig.subscriptionIDForPrivateDB = "AerivoPrivate"
        aerivoSharedConfig.subscriptionIDForSharedDB = "AerivoShared"
        aerivoSharedConfig.publicSubscriptionIDPrefix = "Aerivo-"
        aerivoSharedConfig.contextName = "AerivoFetchAndSave"
        aerivoSharedConfig.userDefaultsKeyTokens = "AerivoCloudKitTokens"
        return aerivoSharedConfig
    }
}
