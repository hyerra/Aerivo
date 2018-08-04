//
//  FavoriteFetchedResultsController.swift
//  AerivoKit
//
//  Created by Harish Yerra on 8/3/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit
import CoreData

/// An `NSFetchedResultsController` for `Favorite`.
public class FavoriteFetchedResultsController: NSFetchedResultsController<Favorite>, NSFetchedResultsControllerDelegate {
    /// The table view you are managing.
    private let tableView: UITableView
    
    /// Whether or not the fetched results controller should update the table view.
    public var shouldUpdateTableView: Bool = false
    
    /// Creates a new fetched results controller.
    ///
    /// - Parameters:
    ///   - managedObjectContext: The managed object context.
    ///   - tableView: The table view you are managing.
    ///   - emptyView: The view to show when there are no results.
    ///   - sectionsResults: Determines if the fetchd results controller should split the results into sections. Defaults to `true`.
    /// - Throws: An error if there was an issue fetching the data from Core Data.
    public init(managedObjectContext: NSManagedObjectContext, tableView: UITableView) throws {
        self.tableView = tableView
        
        let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        let titleSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [titleSortDescriptor]
        super.init(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        delegate = self
        
        try performFetch()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard shouldUpdateTableView else { return }
        tableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard shouldUpdateTableView else { return }
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath else { return }
            guard let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        guard shouldUpdateTableView else { return }
        switch type {
        case .insert:
            let indexSet = IndexSet(integer: sectionIndex)
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            let indexSet = IndexSet(integer: sectionIndex)
            tableView.deleteSections(indexSet, with: .automatic)
        default:
            break
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard shouldUpdateTableView else { return }
        tableView.endUpdates()
    }
}
