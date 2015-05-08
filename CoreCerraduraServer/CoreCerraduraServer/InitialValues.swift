//
//  InitialValues.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 5/8/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData
import CoreCerradura

/** Initial values setup for NSManagedObject that runs only on the server-side. */
internal protocol InitialValues: class {
    
    /** Initial values after creation. */
    func wasCreated(user: User?, context: NSManagedObjectContext)
}