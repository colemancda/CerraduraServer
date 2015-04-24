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
public class LockManager {
    
    // MARK: - Properties
    
    /* Managed object context for Lock entities. */
    public lazy var managedObjectContext: NSManagedObjectContext = PersistenceManager.sharedManager.newManagedObjectContext()
    
    public var locks: Set<Lock> = {
        
        
        
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
        
        
    }
    
}



