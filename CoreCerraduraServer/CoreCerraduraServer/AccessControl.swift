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

/** Defines the access control for an entity. */
public protocol AccessControl: class {
    
    static func userCanCreate(request: ServerRequest, user: User, managedObjectContext: NSManagedObjectContext)
}