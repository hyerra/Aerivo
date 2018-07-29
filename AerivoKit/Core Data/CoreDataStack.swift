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
    
    /// Returns the app's managed object model.
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle(identifier: "com.harishyerra.AerivoKit")!
        let modelURL = bundle.url(forResource: "Aerivo", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    /// Returns the persistent store coordinator for coordinating the persisting of data.
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = applicationSharedGroupContainer.appendingPathComponent("Aerivo.sqlite")
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch let error {
            fatalError("There was an error initalizing the application's stored data: \(error)!")
        }
        
        return coordinator
    }()
    
    /// Returns the managed object context that works as a *scratchpad* for changes before they get persisted.
    public internal(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }()
    
    /// Persists the changes in the managed object context.
    public func saveContext() throws {
        guard managedObjectContext.hasChanges else { return }
        try managedObjectContext.save()
    }
}
