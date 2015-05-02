//
//  LockManager.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 4/21/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData
import NetworkObjects
import CoreCerradura
import CocoaHTTPServer

/* Manages the locks. */
final public class LockManager {
    
    // MARK: - Private Properties
    
    /** Dictionary of pending lock commands. */
    private var lockCommands = [UInt: [LockCommand]]()
}


// MARK: - Stuctures

/** Encapsulates a pending lock command. */
public struct LockCommand {
    
    let type: LockCommandType
    
    let date: NSDate
}

// MARK: - Enumerations

/** Commands issued from the server to the lock. */
public enum LockCommandType: String {
    
    case Unlock = "unlock"
}