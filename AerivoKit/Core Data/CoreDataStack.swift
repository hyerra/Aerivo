//
//  CoreDataStack.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/28/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import CoreData
import CloudCore

/// A container that encapsulates the Core Data stack into the application.
public class AEPersistentContainer: NSPersistentContainer {
    
    #if os(iOS)
    /// The url for the shared container in the app group.
    private static let applicationSharedGroupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.harishyerra.Aerivo")!
    #endif
    
    public override class func defaultDirectoryURL() -> URL {
        #if os(iOS)
        return applicationSharedGroupContainer.appendingPathComponent("AerivoModel")
        #else
        return super.defaultDirectoryURL().appendingPathComponent("AerivoModel")
        #endif
    }
}

/// A data controller that simplifies the interface of interacting with Core Data.
public final class DataController: NSObject {
    
    /// Returns the `DataController` shared instance.
    public static let shared = DataController()
    
    // Make the initializer private to force usage of the `shared` instance.
    private override init() {}
    
    // MARK: - Core Data Stack
    
    /// Returns a persistent container that encapsulates the Core Data stack into the application.
    public internal(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Aerivo")
        
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        container.loadPersistentStores { storeDescription, error in
            #if DEBUG
            if let error = error {
                fatalError(error.localizedDescription)
            }
            #endif
        }
                
        return container
    }()
    
    /// Returns the managed object context that works as a *scratchpad* for changes before they get persisted.
    public internal(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    /// Persists the changes in a the managed object context while making sure it is synced with `CloudCore`.
    ///
    /// - Parameter context: The context to be saved.
    /// - Throws: Throws any errors that can occur when attempting to save.
    public func save(context: NSManagedObjectContext) throws {
        context.name = CloudCore.config.pushContextName
        try context.save()
    }
}
