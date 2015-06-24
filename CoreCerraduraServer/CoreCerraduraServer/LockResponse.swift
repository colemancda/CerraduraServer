//
//  LockResponse.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 5/28/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import CoreCerradura

internal extension LockCommand {
    
    // MARK: - Export to JSON
    
    internal func toJSON() -> [String: Bool] {
        
        return ["update": self.shouldUpdate, "unlock": self.shouldUpdate]
    }
}
