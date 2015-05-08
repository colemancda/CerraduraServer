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
    
    /** Permission for POST requests. */
    static func canCreate(request: ServerRequest, authenticatedUser: User?) -> Bool
    
    /** Permission for attr for GET / PUT / POST requests. */
    func permissionForRequest(request: ServerRequest, authenticatedUser: User?, key: String?, context: NSManagedObjectContext) -> ServerPermission
    
    /** Permission for DELETE requests. */
    func canDelete(request: ServerRequest, authenticatedUser: User?, context: NSManagedObjectContext?) -> Bool
}