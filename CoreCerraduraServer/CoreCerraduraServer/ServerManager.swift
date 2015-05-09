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
        
        return server
        }()
    
    public lazy var persistenceManager: PersistenceManager = PersistenceManager(managedObjectModel: self.server.managedObjectModel)
    
    public lazy var authenticationManager: AuthenticationManager = AuthenticationManager()
    
    public let serverPort: UInt = LoadSetting(Setting.ServerPort) as? UInt ?? 8080
    
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
    
    // MARK: - Actions
    
    /** Starts broadcasting the server. */
    @objc public func start() -> NSError? {
        
        // make sure we have the app support folder
        // self.createApplicationSupportFolderIfNotPresent()
        
        // setup for empty server
        // self.addAdminUserIfEmpty()
        
        // start HTTP server
        return self.server.start(onPort: self.serverPort);
    }
    
    /** Stops broadcasting the server. */
    @objc public func stop() {
        
        self.server.stop();
    }
    
    // MARK: - Methods
    
    // MARK: - Private Methods
    
    private func addLockHandler(server: Server) {
        
        server.httpServer.get("/lock", withBlock: { (request: RouteRequest!, response: RouteResponse!) -> Void in
            
            
            
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
    
    public func server(server: Server, statusCodeForRequest request: ServerRequest, managedObject: NSManagedObject?, context: NSManagedObjectContext, inout userInfo: [String: AnyObject]) -> ServerStatusCode {
        
        // handle authentication...
        
        let httpRequest = request.underlyingRequest as! RouteRequest
        
        let authenticatedUser: User?
        
        if let authorizationHeader = httpRequest.header("Authorization") {
            
            let dateHeader = httpRequest.header("Date")
            
            if dateHeader == nil {
                
                return ServerStatusCode.Unauthorized
            }
            
            let authenticationContext = AuthenticationContext(verb: httpRequest.method(), path: httpRequest.url().path!, dateString: dateHeader)
            
            // get authenticated user...
            
            authenticatedUser = self.authenticationManager.authenticateWithHeader(authorizationHeader, identifierKey: "username", secretKey: "password", entityName: "User", authenticationContext: authenticationContext, managedObjectContext: context) as? User
            
            if authenticatedUser == nil {
                
                return ServerStatusCode.Unauthorized
            }
            
            // set authenticated user in user info
            userInfo[CoreCerraduraServer.ServerUserInfoKey.AuthenticatedUser.rawValue] = authenticatedUser!
        }
        
        return ServerStatusCode.OK
    }
    
    public func server(server: Server, permissionForRequest request: ServerRequest, managedObject: NSManagedObject?, context: NSManagedObjectContext, key: String?, inout userInfo: [String: AnyObject]) -> ServerPermission {
        
        let user = userInfo[CoreCerraduraServer.ServerUserInfoKey.AuthenticatedUser.rawValue] as? User
        
        return PermissionForRequest(request, user, managedObject, key, context)
    }
    
    public func server(server: Server, didInsertManagedObject managedObject: NSManagedObject, context: NSManagedObjectContext, inout userInfo: [String: AnyObject]) {
        
        let user = userInfo[CoreCerraduraServer.ServerUserInfoKey.AuthenticatedUser.rawValue] as? User
        
        if let initialValuesManagedObject = managedObject as? InitialValues {
            
            initialValuesManagedObject.wasCreated(user, context: context)
            
            // no need to save
        }
    }
    
    public func server(server: Server, didPerformRequest request: ServerRequest, withResponse response: ServerResponse, userInfo: [String: AnyObject]) {
        
        
    }
    
    public func server(server: Server, didEncounterInternalError error: NSError, forRequest request: ServerRequest, userInfo: [String: AnyObject]) {
        
        println("Internal server error: \(error)")
    }
}


// MARK: - Enumerations

public enum ServerUserInfoKey: String {
    
    /** Key for getting the authenticated user. */
    case AuthenticatedUser = "AuthenticatedUser"
}
