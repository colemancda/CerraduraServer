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
@objc public class ServerManager: ServerDelegate, ServerDataSource {
    
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
    
    public lazy var lockConnectionDelegate: ServerManagerLockConnectionDelegate = LockManager.sharedManager
    
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
    
    
    
    // MARK: - ServerDelegate
    
    
}

// MARK: - Protocols

/* Delegates how connections with the lock are handled. */
public protocol ServerManagerLockConnectionDelegate {
    
    func serverManager(serverManager: ServerManager, shouldAcceptIncomingLockConnection: ())
}
