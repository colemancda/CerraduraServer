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
    public lazy var managedObjectContext: NSManagedObjectContext = {
       
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        
        context.undoManager = nil
        
        
        
    }()
    
    public var locks: Set<Lock> = {
        
        
        
    }()
    
    // MARK: - Initialization
    
    
    
    // MARK: - Private Methods
    
    private func fetchLocks() -> [Lock] {
        
        
    }
    
}



