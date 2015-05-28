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
    
    public let unlockCommandDuration: NSTimeInterval = LoadSetting(Setting.UnlockCommandDuration) as? NSTimeInterval ?? 5
    
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
        self.createApplicationSupportFolderIfNotPresent()
        
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
            
            // parse authentication header
            
            let dateHeader = request.header(RequestHeader.Date.rawValue)
            
            let authorizationHeader = request.header(RequestHeader.Authorization.rawValue)
            
            if dateHeader == nil || authorizationHeader == nil {
                
                response.statusCode = ServerStatusCode.Unauthorized.rawValue
                
                return
            }
            
            let authenticationContext = AuthenticationContext(verb: request.method(), path: request.url().path!, dateString: dateHeader)
            
            let managedObjectContext = self.persistenceManager.newManagedObjectContext()
            
            let (error, lock) = self.authenticationManager.authenticateWithHeader(authorizationHeader, identifierKey: "id", secretKey: "secret", entityName: "Lock", authenticationContext: authenticationContext, managedObjectContext: managedObjectContext) as! (NSError?, Lock?)
            
            if error != nil {
                
                response.statusCode = ServerStatusCode.InternalServerError.rawValue
                
                return
            }
            
            if lock == nil {
                
                response.statusCode = ServerStatusCode.Unauthorized.rawValue
                
                return
            }
            
            // locks must send version with each request
            
            let firmwareVersion = request.header(LockRequestHeader.FirmwareVersion.rawValue)
            
            let softwareVersion = request.header(LockRequestHeader.SoftwareVersion.rawValue)
            
            if firmwareVersion == nil || softwareVersion == nil {
                
                response.statusCode = ServerStatusCode.BadRequest.rawValue
                
                return
            }
            
            // get last unlock action...
            
            var shouldUnlock: Bool = false
            
            var unlockError: NSError?
            
            managedObjectContext.performBlockAndWait({ () -> Void in
                
                let fetchRequest = NSFetchRequest(entityName: "Action")
                
                fetchRequest.predicate = NSPredicate(format: "lock == %@ && type == unlocked && status == pending", argumentArray: [lock!])
                
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                
                let unlockActions = managedObjectContext.executeFetchRequest(fetchRequest, error: &unlockError)?.first as? [Action]
                
                if unlockError == nil {
                    
                    return
                }
                
                
                for action in unlockActions! {
                    
                    // expired
                    if NSDate() > NSDate(timeInterval: self.unlockCommandDuration, sinceDate: action.date) {
                        
                        action.status = ActionStatus.Expired.rawValue
                    }
                    
                    // mark as completed
                    else {
                        
                        if shouldUnlock == false {
                            
                            shouldUnlock = true
                        }
                        
                        action.status = ActionStatus.Completed.rawValue
                    }
                }
                
                // save
                managedObjectContext.save(&unlockError)
                
                return
            })
            
            if unlockError != nil {
                
                response.statusCode = ServerStatusCode.InternalServerError.rawValue
                
                return
            }
            
            var shouldUpdate: Bool = false
            
            // TODO: Handle Updating Lock
            
            
            
            let lockResponse = LockResponse(update: shouldUpdate, unlock: shouldUnlock)
            
            // send JSON response
            
            let jsonData = NSJSONSerialization.dataWithJSONObject(lockResponse.toJSON(), options: NSJSONWritingOptions.PrettyPrinted, error: nil)!
            
            response.respondWithData(jsonData)
        })
    }
    
    private func createApplicationSupportFolderIfNotPresent() {
        
        let fileExists = NSFileManager.defaultManager().fileExistsAtPath(ServerApplicationSupportFolderURL.path!, isDirectory: nil)
        
        if !fileExists {
            
            var error: NSError?
            
            // create directory
            NSFileManager.defaultManager().createDirectoryAtURL(ServerApplicationSupportFolderURL, withIntermediateDirectories: true, attributes: nil, error: &error)
            
            if error != nil {
                
                NSException(name: NSInternalInconsistencyException, reason: "Could not create application support directory. (\(error!.localizedDescription))", userInfo: nil).raise()
            }
        }
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
        context: NSManagedObjectContext, recievedJsonObject: [String: AnyObject]?, request: ServerRequest, inout userInfo: [String: AnyObject]) -> (ServerFunctionCode, [String: AnyObject]?) {
            
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
                
                let authenticatedUser = userInfo[ServerUserInfoKey.AuthenticatedUser.rawValue] as! User
                
                // create new pending action...
                
                var error: NSError?
                
                var permission: Permission?
                
                context.performBlockAndWait({ () -> Void in
                    
                    // fetch permssion
                    
                    permission = {
                       
                        let fetchRequest = NSFetchRequest(entityName: "Permission")
                        
                        fetchRequest.predicate = NSPredicate(format: "user == %@ && lock == %@", argumentArray: [authenticatedUser, lock])
                        
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
                        
                        fetchRequest.fetchLimit = 1
                        
                        // TODO: Verify permission
                        
                        return context.executeFetchRequest(fetchRequest, error: &error)?.first as? Permission
                    }()
                    
                    if error != nil {
                        
                        return
                    }
                    
                    return
                })
                
                if error != nil {
                    
                    return (.InternalErrorPerformingFunction, nil)
                }
                
                if permission == nil {
                    
                    return (.CannotPerformFunction, nil)
                }
                
                // create new action
                
                context.performBlockAndWait({ () -> Void in
                    
                    let unlockAction = NSEntityDescription.insertNewObjectForEntityForName("Action", inManagedObjectContext: context) as! Action
                    
                    unlockAction.type = ActionType.Unlock.rawValue
                    
                    unlockAction.status = ActionStatus.Pending.rawValue
                    
                    unlockAction.lock = lock
                    
                    unlockAction.user = authenticatedUser
                    
                    unlockAction.permission = permission!
                    
                    context.save(&error)
                })
                
                if error != nil {
                    
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
        
        if let authorizationHeader = httpRequest.header(RequestHeader.Authorization.rawValue) {
            
            let dateHeader = httpRequest.header(RequestHeader.Date.rawValue)
            
            if dateHeader == nil {
                
                return ServerStatusCode.Unauthorized
            }
            
            let authenticationContext = AuthenticationContext(verb: httpRequest.method(), path: httpRequest.url().path!, dateString: dateHeader)
            
            // get authenticated user...
            
            let (error, user) = self.authenticationManager.authenticateWithHeader(authorizationHeader, identifierKey: "username", secretKey: "password", entityName: "User", authenticationContext: authenticationContext, managedObjectContext: context) as! (NSError?, User?)
            
            if error != nil {
                
                return ServerStatusCode.InternalServerError
            }
            
            if user == nil {
                
                return ServerStatusCode.Unauthorized
            }
                        
            // set authenticated user in user info
            userInfo[CoreCerraduraServer.ServerUserInfoKey.AuthenticatedUser.rawValue] = user!
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
