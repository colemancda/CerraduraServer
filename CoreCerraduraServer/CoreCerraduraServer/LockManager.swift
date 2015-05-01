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
final public class LockManager: WebSocketDelegate {
    
    // MARK: - Properties
    
    /* Managed object context for Lock entities. */
    public let managedObjectContext: NSManagedObjectContext
    
    // MARK: - Private Properties
    
    /** Operation queue for accessing variables in a thread safe manner. */
    private let lockOperationQueue: NSOperationQueue = {
        
        let operationQueue = NSOperationQueue()
        
        operationQueue.name = "LockManager Operation Queue"
        
        operationQueue.maxConcurrentOperationCount = 1
        
        return operationQueue
    }()
    
    private var locks = Set<Lock>()
    
    private var lockConnections = [Lock: WebSocket]()
    
    // MARK: - Initialization
    
    public init(managedObjectContext: NSManagedObjectContext) {
        
        self.managedObjectContext = managedObjectContext
        
        self.managedObjectContext.name = "LockManager Managed Object Context"
    }
    
    // MARK: - Methods
    
    /** Initial setup for loading locks and setting their initial values. You need to call this once for LockManager to properly manage the locks. Thread-safe. */
    public func loadLocks() -> NSError? {
        
        let (fetchLocksError, fetchedLocks) = self.fetchLocks()
        
        if fetchLocksError != nil {
            
            return fetchLocksError!
        }
        
        self.lockOperationQueue.addOperations([NSBlockOperation(block: { () -> Void in
            
            // keep reference to locks
            
            self.locks = Set(fetchedLocks!)
            
            // set initial values
            
            for lock in self.locks {
                
                var online = false
                
                // detect connection with lock
                
                let connection = self.lockConnections[lock]
                
                
                
                lock.online = false
            }
            
        })], waitUntilFinished: true)
        
        return nil
    }
    
    /** Unlocks a lock if possible. Does not check for permissions, only whether the lock is connected to the server. Lock must belong to the manager's managed object context. */
    public func attemptUnlock(lock: Lock) -> Bool {
        
        let connection: WebSocket? = {
            
            var connection: WebSocket?
            
            self.lockOperationQueue.addOperations([NSBlockOperation(block: { () -> Void in
                
                connection = self.lockConnections[lock]
                
            })], waitUntilFinished: true)
        }()
        
        if connection == nil {
            
            return false
        }
        
        let unlockMessage = LockCommand.Unlock.rawValue
        
        //
        
        connection!.sendMessage(unlockMessage)
    }
    
    /* Adds a new WebSocket to the manager. Tries to find a lock associated with the incoming connection and validate identity. */
    public func addLockConnection(webSocket: WebSocket) {
        
        // set delegate to self, we'll validate identity once the websocket opens
        webSocket.delegate = self
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
    
    // MARK: - WebSocketDelegate
    
    public func webSocketDidOpen(ws: WebSocket!) {
        
        // validate identity
        
        
        
        // set the lock's online property to true
        
        
    }
    
    public func webSocket(ws: WebSocket!, didReceiveMessage msg: String!) {
        
        
    }
    
    public func webSocketDidClose(ws: WebSocket!) {
        
        // remove from lock connections
        
    }
    
}

// MARK: - Enumerations

/** Commands issued from the server to the lock. */
public enum LockCommand: String {
    
    case Unlock = "unlock"
}

/** Responses from the lock, to the server after a LockCommand request. */
public enum LockResponse: String {
    
    case Success = "success"
    case Failure = "failure"
}


