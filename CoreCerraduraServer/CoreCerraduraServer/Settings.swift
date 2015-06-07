//
//  Settings.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 4/23/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation

// MARK: - Structs

/** Settings for Cerradura Server. */
public struct Setting {
    
    public static let ServerPort = SettingInfo<UInt>(key: "ServerPort", defaultValue: 8080)
    
    public static let AnyUserAddLocks = SettingInfo<Bool>(key: "AnyUserAddLocks", defaultValue: false)
    
    public static let AuthorizationHeaderTimeout = SettingInfo<NSTimeInterval>(key: "AuthorizationHeaderTimeout", defaultValue: 30)
    
    public static let UnlockCommandDuration = SettingInfo<NSTimeInterval>(key: "UnlockCommandDuration", defaultValue: 5)
}

public class SettingInfo<T> {
    
    public let key: String
    
    public let defaultValue: T
    
    /** Fetches the value from disk, or returns the default value. The setter saves the value to disk. */
    public var value: T {
        
        get {
            
            // try to load archived settings
            let archivedServerSettings = NSDictionary(contentsOfURL: ServerSettingsFileURL) as? [String: AnyObject]
            
            return archivedServerSettings?[self.key] as? T ?? self.defaultValue
        }
        
        set {
            
            // try to load archived settings
            var currentSettings = NSDictionary(contentsOfURL: ServerSettingsFileURL) as? [String: AnyObject]
            
            // new settings
            if currentSettings == nil {
                
                currentSettings = [String: AnyObject]()
            }
            
            // set new setting value
            currentSettings![self.key] = value as? AnyObject
            
            // try to save
            if !NSDictionary(dictionary: currentSettings!).writeToURL(ServerSettingsFileURL, atomically: true) {
                
                fatalError("Could not save value \(value) for \(self.key) setting")
            }
        }
    }
    
    /** Lazily loads the setting once per application lifetime. */
    public lazy var staticValue: T = {
        
        return self.value
    }()
    
    // MARK: - Initalization
    
    public init(key: String, defaultValue: T) {
        
        self.key = key
        self.defaultValue = defaultValue
    }
}