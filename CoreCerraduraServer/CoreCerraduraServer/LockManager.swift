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
import CocoaHTTPServer

/* Manages the connections to the locks. */
public class LockManager {
    
    // MARK: - Properties
    
    public var locks = Set<Lock>()
    
    public var lockConnections = [Lock: WebSocket]()
    
    /* Managed object context for Lock entities. */
    public let managedObjectContext: NSManagedObjectContext
    
    // MARK: - Private Properties
    
    private let lockOperationQueue: NSOperationQueue = {
        
        let operationQueue = NSOperationQueue()
        
        operationQueue.name = "LockManager Operation Queue"
        
        operationQueue.maxConcurrentOperationCount = 1
        
        return operationQueue
    }()
    
    // MARK: - Initialization
    
    public init(managedObjectContext: NSManagedObjectContext) {
        
        self.managedObjectContext = managedObjectContext
        
        self.managedObjectContext.name = "LockManager Managed Object Context"
    }
    
    // MARK: - Methods
    
    /** Initial setup for loading locks and setting their initial values. You need to call this once for LockManager to properly manage the locks. */
    public func loadLocks() -> NSError? {
        
        let (fetchLocksError, fetchedLocks) = self.fetchLocks()
        
        if fetchLocksError != nil {
            
            return fetchLocksError!
        }
        
        // keep reference to locks
        
        self.locks = Set(fetchedLocks!)
        
        // set initial values
        
        for lock in self.locks {
            
            // TODO: detect connection with lock
            
            lock.online = false
        }
        
        return nil
    }
    
    /** Unlocks a lock if possible. Does not check for permissions, only whether the lock is connected to the server. Lock must belong to the manager's managed object context. */
    public func unlock(lock: Lock) -> Bool {
        
        let connection = self.lockConnections[lock]
        
        if connection == nil {
            
            return false
        }
        
        
        
        return true
    }
    
    // MARK: - Private Methods
    
    /** Fetches the locks from the managed object context. */
    private func fetchLocks() -> (NSError?, [Lock]?) {
        
        let fetchRequest = NSFetchRequest(entityName: "Lock")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        fetchRequest.predicate = NSPredicate(format: "archived == NO", argumentArray: nil);
        
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