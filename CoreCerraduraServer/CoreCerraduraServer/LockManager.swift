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

/* Manages the connections to the locks. */
@objc public class LockManager: LockPersistenceDelegate, ServerManagerLockConnectionDelegate {
    
    // MARK: - Properties
    
    public var locks = Set<Lock>()
    
    // MARK: - Private Properties
    
    /* Managed object context for Lock entities. */
    private let managedObjectContext: NSManagedObjectContext = PersistenceManager.sharedManager.newManagedObjectContext()
    
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
    
    // MARK: - Methods
    
    /** Initial setup for loading locks and setting their initial values. You need to call this once for LockManager to properly manage the locks. */
    public func loadLocks() -> NSError {
        
        let (fetchLocksError, fetchedLocks) = self.fetchLocks()
        
        if fetchLocksError != nil {
            
            return fetchLocksError!
        }
        
        // keep reference to locks
        
        self.locks = Set(fetchedLocks!)
        
        // set initial values
        
        for lock in self.locks {
            
            if ()
        }
    }
    
    /** Objective-C compatible method for 'func loadLocks() -> NSError' */
    public func loadLocks(error: NSErrorPointer) -> Bool {
        
        error.memory = self.loadLocks()
        
        return (error.memory == nil)
    }
    
    // MARK: - Private Methods
    
    /** Fetches the locks from the managed object context. */
    private func fetchLocks() -> (NSError?, [Lock]?) {
        
        let fetchRequest = NSFetchRequest(entityName: "Lock")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        var results: [Lock]?
        
        var fetchError: NSError?
        
        self.managedObjectContext.performBlockAndWait { () -> Void in
            
            results = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &fetchError) as? [Lock]
            
            return
        }
        
        // error
        if fetchError != nil {
            
            return (fetchError, nil)
        }
        
        // set locks array
        return (nil, results)
    }
    
}

// MARK: - Protocols

public protocol LockPersistenceDelegate {
    
    
}