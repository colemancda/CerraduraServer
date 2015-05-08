//
//  UserAccessControl.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 5/7/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData
import NetworkObjects
import CoreCerradura

extension User: AccessControl {
    
    public static func permissionForRequest(request: ServerRequest, authenticatedUser: User?, managedObject: NSManagedObject?, key: String?, context: NSManagedObjectContext?) -> ServerPermission {
        
        if 
        
        return ServerPermission.EditPermission
    }
    
    
}