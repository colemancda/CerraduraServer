//
//  LockManager.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 4/21/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData
import NetworkObjects
import CoreCerradura
import SNRFetchedResultsController

/* Manages the connections to the locks. */
public class LockManager {
    
    // MARK: - Properties
    
    
    
    // MARK: - Private Properties
    
    /* Managed object context for Lock entities. */
    private lazy var managedObjectContext: NSManagedObjectContext = PersistenceManager.sharedManager.newManagedObjectContext()
    
    /** Fetched results controller for fetching locks. */
    private lazy var fetchedResultsController: SNRFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Lock")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
       
        let fetchedResultsController = SNRFetchedResultsController(managedObjectContext: self.managedObjectContext, fetchRequest: fetchRequest)
        
        let fetchError: NSError?
        
        if !fetchedResultsController.performFetch(&fetchError) {
            
            NSException(name: NSInternalInconsistencyException, reason: "Could not perform initial fetch for LockManager", userInfo: nil).raise()
        }
        
        return fetchedResultsController
    }()
    
    // MARK: - Initialization
    
    public class var sharedManager : LockManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : LockManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = LockManager()
        }
        return Static.instance!
    }
    
    // MARK: - Private Methods
    
    private func fetchLocks() -> [Lock] {
        
        self.managedObjectContext.performBlockAndWait { () -> Void in
            
            
            
            
        }
    }
    
}



