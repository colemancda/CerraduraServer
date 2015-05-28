//
//  LockResponse.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 5/28/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

/** Response for the lock requests. */
internal struct LockResponse {
    
    // MARK: - Properties
    
    internal let update: Bool
    
    internal let unlock: Bool
    
    // MARK: - Initialization
    
    init(update: Bool = false, unlock: Bool = false){
        
        self.update = update
        self.unlock = unlock
    }
    
    // MARK: - Export to JSON
    
    internal func toJSON() -> [String: Bool] {
        
        return ["update": self.update, "unlock": self.unlock]
    }
}
