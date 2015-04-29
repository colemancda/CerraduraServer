//
//  PersistenceManager.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 4/23/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData


/* Manages persistence of object graph. */
public class PersistenceManager {
    
    // MARK: - Properties
    
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: ServerManager.sharedManager.server.managedObjectModel)
        
        var error: NSError?
        
        if persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: ServerSQLiteFileURL, options: nil, error: &error) == nil {
            
            NSException(name: NSInternalInconsistencyException, reason: "Could not add persistent store. (\(error!.localizedDescription))", userInfo: nil)
        }
        
        return persistentStoreCoordinator
        }()
    
    // MARK: - Private Properties
    
    private var lastResourceIDByEntityName: NSMutableDictionary = NSMutableDictionary(contentsOfURL: ServerLastResourceIDByEntityNameFileURL) ?? NSMutableDictionary()
    
    private var lastResourceIDByEntityNameOperationQueue: NSOperationQueue = {
        
        let operationQueue = NSOperationQueue()
        
        operationQueue.name = "CoreCerraduraServer.ServerManager lastResourceIDByEntityName Access Queue"
        
        operationQueue.maxConcurrentOperationCount = 1
        
        return operationQueue
        }()
    
    // MARK: - Methods
    
    public func newManagedObjectContext() -> NSManagedObjectContext {
        
        // create a new managed object context
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        
        managedObjectContext.undoManager = nil
        
        // setup persistent store coordinatormanagedObjectContext
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }
    
    public func newResourceIDForEntity(entityName: String) -> UInt {
        
        // create new resourceID
        var newResourceID = UInt(0)
        
        self.lastResourceIDByEntityNameOperationQueue.addOperations([NSBlockOperation(block: { () -> Void in
            
            // get last resource ID and increment by 1
            if let lastResourceID = self.lastResourceIDByEntityName[entityName] as? UInt {
                
                newResourceID = lastResourceID + 1;
            }
            
            // save new one
            self.lastResourceIDByEntityName[entityName] = newResourceID;
            
            if !(self.lastResourceIDByEntityName as NSDictionary).writeToURL(ServerLastResourceIDByEntityNameFileURL, atomically: true) {
                
                NSException(name: NSInternalInconsistencyException, reason: "Could not save lastResourceIDByEntityName dictionary to disk", userInfo: nil)
            }
            
        })], waitUntilFinished: true)
        
        return newResourceID
    }
}