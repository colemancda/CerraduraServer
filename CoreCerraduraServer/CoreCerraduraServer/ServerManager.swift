//
//  ServerManager.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 4/20/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData
import NetworkObjects
import CoreCerradura
import CocoaAsyncSocket

/* Manages incoming connections to the server. */
@objc public class ServerManager: ServerDataSource, ServerDelegate {
    
    // MARK: - Properties
    
    public lazy var server: Server = {
        
        // create server
        let server = Server(dataSource: self,
            delegate: self,
            managedObjectModel: CoreCerraduraManagedObjectModel(),
            prettyPrintJSON: true,
            sslIdentityAndCertificates: nil,
            permissionsEnabled: true)
        
        return server
        }()
    
    public lazy var lockManager: LockManager = {
        
        let lockManager = LockManager()
        
        return lockManager
    }
    
    public lazy var persistenceManager: PersistenceManager = {
        
        
    }
    
    // MARK: - Initialization
    
    public class var sharedManager : ServerManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : ServerManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = ServerManager()
        }
        return Static.instance!
    }
    
    // MARK: - Methods
    
    
    
    // MARK: - ServerDataSource
    
    public func server(server: Server, managedObjectContextForRequest request: ServerRequest) -> NSManagedObjectContext {
        
        return self.persistenceManager.newManagedObjectContext()
    }
    
    public func server(server: Server, newResourceIDForEntity entity: NSEntityDescription) -> UInt {
        
        return self.persistenceManager.newResourceIDForEntity(entity.name!)
    }
    
    public func server(server: Server, functionsForEntity entity: NSEntityDescription) -> [String] {
        
        // get class
        
        let entityClass: AnyClass! = NSClassFromString(entity.managedObjectClassName)
        
        let functionNames = [String]()
        
        if entityClass is Archiveable {
            
            
        }
    }
    
    public func server(server: Server, performFunction functionName:String, forManagedObject managedObject: NSManagedObject,
        context: NSManagedObjectContext, recievedJsonObject: [String: AnyObject]?, request: ServerRequest) -> (ServerFunctionCode, [String: AnyObject]?) {
            
            
    }
    
    // MARK: - ServerDelegate
    
    public func server(server: Server, didEncounterInternalError error: NSError, forRequest request: ServerRequest, userInfo: [ServerUserInfoKey: AnyObject]) {
        
        println("Internal server error: \(error)")
    }
    
    public func server(server: Server, statusCodeForRequest request: ServerRequest, managedObject: NSManagedObject?, context: NSManagedObjectContext) -> ServerStatusCode {
        
        
    }
    
    public func server(server: Server, permissionForRequest request: ServerRequest, managedObject: NSManagedObject?, context: NSManagedObjectContext, key: String?) -> ServerPermission {
        
        
    }
    
    public func server(server: Server, didInsertManagedObject managedObject: NSManagedObject, context: NSManagedObjectContext) {
        
        
    }
    
    public func server(server: Server, didPerformRequest request: ServerRequest, withResponse response: ServerResponse, userInfo: [ServerUserInfoKey: AnyObject]) {
        
        
    }
}

// MARK: - Protocols

/* Delegates how connections with the lock are handled. */
public protocol ServerManagerLockConnectionDelegate {
    
    func serverManager(serverManager: ServerManager, shouldAcceptIncomingLockConnection: ())
}
