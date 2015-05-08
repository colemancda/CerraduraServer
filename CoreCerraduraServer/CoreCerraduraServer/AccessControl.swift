//
//  AccessControl.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 5/7/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData
import NetworkObjects
import CoreCerradura

/** Defines the access control for an entity. */
internal protocol AccessControl: class {
    
    /** Asks the reciever for access control. */
    static func permissionForRequest(request: ServerRequest, authenticatedUser: User?, managedObject: NSManagedObject?, key: String?, context: NSManagedObjectContext?) -> ServerPermission
}

/** Workaround for Swift not implementing class function or properties in protocols. */
internal func PermissionForRequest(request: ServerRequest, user: User?, managedObject: NSManagedObject?, key: String?, context: NSManagedObjectContext?) -> ServerPermission {
    
    switch request.entity.name! {
        
        case "User": return User.permissionForRequest(request, authenticatedUser: user, managedObject: managedObject, key: key, context: context)
        
        case "Lock": return User.permissionForRequest(request, authenticatedUser: user, managedObject: managedObject, key: key, context: context)
        
        case "Permission": return User.permissionForRequest(request, authenticatedUser: user, managedObject: managedObject, key: key, context: context)
        
        case "LockCommand": return User.permissionForRequest(request, authenticatedUser: user, managedObject: managedObject, key: key, context: context)
        
        case "Action": return User.permissionForRequest(request, authenticatedUser: user, managedObject: managedObject, key: key, context: context)
        
    default: return ServerPermission.NoAccess
    }
}