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
import CocoaHTTPServer
import RoutingHTTPServer
import ExSwift

/* Manages incoming connections to the server. */
@objc final public class ServerManager: ServerDataSource, ServerDelegate {
    
    // MARK: - Properties
    
    public lazy var server: Server = {
        
        let prettyPrintJSON: Bool
        
        #if DEBUG
            prettyPrintJSON = true
        #else
            prettyPrintJSON = false
        #endif
        
        // create server
        let server = Server(dataSource: self,
            delegate: self,
            managedObjectModel: CoreCerraduraManagedObjectModel(),
            searchPath: "search",
            resourceIDAttributeName: "id",
            prettyPrintJSON: true,
            sslIdentityAndCertificates: nil,
            permissionsEnabled: true)
        
        self.addLockHandler(server)
        
        self.addLoginHandler(server)
        
        return server
        }()
    
    public lazy var persistenceManager: PersistenceManager = PersistenceManager(managedObjectModel: self.server.managedObjectModel)
    
    public lazy var authenticationManager: AuthenticationManager = AuthenticationManager()
    
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
    
    // MARK: - Private Methods
    
    private func addLockHandler(server: Server) {
        
        server.httpServer.get("/lock", withBlock: { (request: RouteRequest!, response: RouteResponse!) -> Void in
            
            
            
        })
    }
    
    private func addLoginHandler(server: Server) {
        
        server.httpServer.post("/login", withBlock: { (request: RouteRequest!, response: RouteResponse!) -> Void in
            
            // get JSON object
            
            let authenticationObject = NSJSONSerialization.JSONObjectWithData(request.body(), options: .allZeros, error: nil) as? [String: String]
            
            if authenticationObject?.count != 1 || authenticationObject == nil {
                
                response.statusCode = ServerStatusCode.BadRequest.rawValue
                
                return
            }
            
            let username = authenticationObject!.keys.first!
            
            let password = authenticationObject!.values.first!
            
            let context = self.persistenceManager.newManagedObjectContext()
            
            // fetch user 
            
            var user: User?
            
            var fetchError: NSError?
            
            context.performBlockAndWait({ () -> Void in
                
                let fetchRequest = NSFetchRequest(entityName: "User")
                
                fetchRequest.predicate = NSPredicate(format: "username == %@ && password == %@", argumentArray: [username, password])
                
                fetchRequest.fetchLimit = 1
                
                let result = context.executeFetchRequest(fetchRequest, error: &fetchError)
                
                user = result?.first as? User
            })
            
            if fetchError != nil {
                
                response.statusCode = ServerStatusCode.InternalServerError.rawValue
                
                return
            }
            
            if user == nil {
                
                response.statusCode = ServerStatusCode.BadRequest.rawValue
                
                return
            }
            
            
            
        })
    }
    
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
        
        var functionNames = [String]()
        
        // archiveable function
        
        if entityClass is Archivable {
            
            functionNames += [ArchiveFunctionName]
        }
        
        // lock
        
        if entity.name == "Lock" {
            
            functionNames += [UnlockFunctionName]
        }
        
        return functionNames
    }
    
    public func server(server: Server, performFunction functionName: String, forManagedObject managedObject: NSManagedObject,
        context: NSManagedObjectContext, recievedJsonObject: [String: AnyObject]?, request: ServerRequest) -> (ServerFunctionCode, [String: AnyObject]?) {
            
            switch functionName {
                
            case ArchiveFunctionName:
                
                // archive object
                
                let archivable = managedObject as! Archivable
                
                // save changes
                
                var error: NSError?
                
                context.performBlockAndWait({ () -> Void in
                    
                    Archive(archivable)
                    
                    context.save(&error)
                })
                
                if error != nil {
                    
                    return (.InternalErrorPerformingFunction, nil)
                }
                
                return (.PerformedSuccesfully, nil)
                
            case UnlockFunctionName:
                
                // unlock lock
                
                let lock = managedObject as! Lock
                
                // create new pending command
                
                var saveError: NSError?
                
                context.performBlockAndWait({ () -> Void in
                    
                    let lockCommand = NSEntityDescription.insertNewObjectForEntityForName("LockCommand", inManagedObjectContext: context) as! LockCommand
                    
                    lockCommand.command = LockCommandType.Unlock.rawValue
                    
                    lockCommand.lock = lock
                    
                    context.save(&saveError)
                })
                
                if saveError != nil {
                    
                    return (.InternalErrorPerformingFunction, nil)
                }
                
                return (.PerformedSuccesfully, nil)
                
            default:
                
                break
            }
            
            // this should never be called
            return (.InternalErrorPerformingFunction, nil)
    }
    
    // MARK: - ServerDelegate
    
    public func server(server: Server, didEncounterInternalError error: NSError, forRequest request: ServerRequest, userInfo: [ServerUserInfoKey: AnyObject]) {
        
        println("Internal server error: \(error)")
    }
    
    public func server(server: Server, statusCodeForRequest request: ServerRequest, managedObject: NSManagedObject?, context: NSManagedObjectContext) -> ServerStatusCode {
        
        return ServerStatusCode.OK
    }
    
    public func server(server: Server, permissionForRequest request: ServerRequest, managedObject: NSManagedObject?, context: NSManagedObjectContext, key: String?) -> ServerPermission {
        
        return ServerPermission.EditPermission
    }
    
    public func server(server: Server, didInsertManagedObject managedObject: NSManagedObject, context: NSManagedObjectContext) {
        
        
    }
    
    public func server(server: Server, didPerformRequest request: ServerRequest, withResponse response: ServerResponse, userInfo: [ServerUserInfoKey: AnyObject]) {
        
        
    }
}
