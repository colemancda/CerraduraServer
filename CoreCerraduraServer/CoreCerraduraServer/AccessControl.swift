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
public protocol AccessControl: class {
    
    /** Asks the reciever for access control. */
    static func permissionForRequest(request: ServerRequest, authenticatedUser: User?, managedObject: NSManagedObject?, key: String?, context: NSManagedObjectContext?) -> ServerPermission
}