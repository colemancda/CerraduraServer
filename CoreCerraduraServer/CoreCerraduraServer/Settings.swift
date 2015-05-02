//
//  Settings.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 4/23/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation

// MARK: - Enumerations

public enum Setting: String {
    
    case ServerPort = "ServerPort"
    case SessionTokenLength = "SessionTokenLength"
    case SessionExpiryTimeInterval = "SessionExpiryTimeInterval"
    case AnyUserAddLocks = "AnyUserAddLocks"
}

// MARK: - Functions

/** Load the saved Server setting value from disk. */
public func LoadSetting(serverSetting: Setting) -> AnyObject? {
    
    // try to load archived settings
    let archivedServerSettings = NSDictionary(contentsOfURL: ServerSettingsFileURL) as? [String: AnyObject]
    
    return archivedServerSettings?[serverSetting.rawValue]
}

/** Saves the specified setting to disk. */
public func SaveSetting(serverSetting: Setting, value: AnyObject) -> Bool {
    
    // try to load archived settings
    var currentSettings = NSDictionary(contentsOfURL: ServerSettingsFileURL) as? [String: AnyObject]
    
    // new settings
    if currentSettings == nil {
        
        currentSettings = [String: AnyObject]()
    }
    
    // set new setting value
    currentSettings![serverSetting.rawValue] = value
    
    // try to save
    return NSDictionary(dictionary: currentSettings!).writeToURL(ServerSettingsFileURL, atomically: true)
}