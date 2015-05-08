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
    
    static func permissionForRequest(request: ServerRequest, authenticatedUser: User?, managedObject: NSManagedObject?, key: String?, context: NSManagedObjectContext?) -> ServerPermission {
        
        
        
        // creation
        if authenticatedUser == nil && request.requestType == ServerRequestType.POST {
            
            
        }
        
        if key != nil {
            
            switch key! {
                
                case "archived": return ServerPermission.ReadOnly
                
                case "created": return ServerPermission.ReadOnly
                
                case "emailValidated": return ServerPermission.ReadOnly
                
                case "actions": ServerPermission.ReadOnly
                
                case "username":
                
                    if request.requestType == ServerRequestType.POST {
                        
                        return ServerPermission.EditPermission
                    }
                    
                    return ServerPermission.ReadOnly
                
                case "email":
                
                    if authenticatedUser == managedObject {
                        
                        return ServerPermission.EditPermission
                    }
                    
                    return ServerPermission.NoAccess
                
                case "password":
                
                    if request.requestType == ServerRequestType.POST {
                        
                        return ServerPermission.EditPermission
                    }
                    
                    return ServerPermission.NoAccess
                
            default: return ServerPermission.ReadOnly
                
            }
        }
        
        return ServerPermission.ReadOnly
    }
    
    
}