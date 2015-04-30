//
//  Server.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 4/30/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import NetworkObjects
import CocoaHTTPServer

public class Server: NetworkObjects.Server {
    
    /** Delegates the WebSocket connections with the locks. */
    let lockConnectionDelegate: ServerLockConnectionDelegate
    
    init(dataSource: ServerDataSource, delegate: ServerDelegate?, managedObjectModel: NSManagedObjectModel, searchPath: String?, resourceIDAttributeName: String, prettyPrintJSON: Bool, sslIdentityAndCertificates: [AnyObject]?, permissionsEnabled: Bool, lockConnectionDelegate: ServerLockConnectionDelegate) {
        
        self.lockConnectionDelegate = lockConnectionDelegate
        
        super.init(dataSource: dataSource, delegate: delegate, managedObjectModel: managedObjectModel, searchPath: searchPath, resourceIDAttributeName: resourceIDAttributeName, prettyPrintJSON: prettyPrintJSON, sslIdentityAndCertificates: sslIdentityAndCertificates, permissionsEnabled: permissionsEnabled)
        
        self.httpServer.setConnectionClass(ServerHTTPConnection)
    }
}

public class ServerHTTPConnection: NetworkObjects.ServerHTTPConnection {
    
    override public func webSocketForURI(path: String!) -> WebSocket! {
        
        if path == "/lock" {
            
            let webSocket = WebSocket(request: request, socket: socket)
            
            let cocoaHTTPServer: CocoaHTTPServer.HTTPServer = self.config().server
            
            let httpServer = cocoaHTTPServer as! ServerHTTPServer
            
            let server = httpServer.server as! Server
            
            server.lockConnectionDelegate.server(server, newLockConnection: webSocket)
            
            return webSocket
        }
        
        return super.webSocketForURI(path)
    }
}

/** Delegates the WebSocket connections with the locks. */
public protocol ServerLockConnectionDelegate: class {
    
    /** Handle new incoming connection. */
    func server(server: Server, newLockConnection websocket: WebSocket)
}

