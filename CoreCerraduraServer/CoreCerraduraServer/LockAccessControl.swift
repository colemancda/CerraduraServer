//
//  LockAccessControl.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 5/8/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData
import NetworkObjects
import CoreCerradura

extension Lock: AccessControl {
    
    static func permissionForRequest(request: ServerRequest, authenticatedUser: User?, managedObject: NSManagedObject?, key: String?, context: NSManagedObjectContext?) -> ServerPermission {
        
        return ServerPermission.EditPermission
    }
    
    
}