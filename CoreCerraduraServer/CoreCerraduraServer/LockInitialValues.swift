//
//  LockInitialValues.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 5/8/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData
import CoreCerradura
import ExSwift

extension Lock: InitialValues {
    
    func wasCreated(user: User?, context: NSManagedObjectContext) {
        
        // create secret (alphanumeric)
        
        self.secret = String.random(length: LockSecretLength)
    }
}

internal let LockSecretLength = 50