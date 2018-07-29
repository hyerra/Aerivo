//
//  CoreDataStack.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/28/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit
import CoreData

/// A data controller that simplifies the interface of interacting with Core Data.
public final class DataController: NSObject {
    
    /// Returns the `DataController` shared instance.
    public static let shared = DataController()
    
    // Make the initializer private to force usage of the `shared` instance.
    private override init() {}
    
    // MARK: - Core Data Stack
    
    /// The url for the shared container in the app group.
    private lazy var applicationSharedGroupContainer: URL = {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.harishyerra.Aerivo")
        return url!
    }()
    
    /// Returns a persistent container that encapsulates the Core Data stack into the application.
    public internal(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Aerivo")
        
        #if os(iOS)
        let description = NSPersistentStoreDescription(url: applicationSharedGroupContainer.appendingPathComponent("Aerivo.sqlite"))
        container.persistentStoreDescriptions = [description]
        #endif
        
        container.loadPersistentStores { storeDescription, error in
            #if DEBUG
            fatalError(error?.localizedDescription ?? "Error initializing core data stack.")
            #endif
        }
        
        CloudCore.enable(persistentContainer: container)
        
        return container
    }()
    
    /// Returns the managed object context that works as a *scratchpad* for changes before they get persisted.
    public internal(set) lazy var managedObjectContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    /// Persists the changes in the managed object context. Optionally pushing changes to CloudKit..
    ///
    /// - Parameter shouldPushChangesToCloudKit: Whether or not to push changes to CloudKit.
    /// - Throws: Throws any errors that can occur when attempting to save.
    public func saveContext(pushingChangesToCloudKit shouldPushChangesToCloudKit: Bool) throws {
        guard managedObjectContext.hasChanges else { return }
        try managedObjectContext.save()
    }
}
