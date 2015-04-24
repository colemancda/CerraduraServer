//
//  File.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 12/9/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

import Foundation

// MARK: - Constants

public let ServerApplicationSupportFolderURL: NSURL = NSFileManager.defaultManager().URLForDirectory(.ApplicationSupportDirectory, inDomain: NSSearchPathDomainMask.LocalDomainMask, appropriateForURL: nil, create: false, error: nil)!.URLByAppendingPathComponent("CerraduraServer")

public let ServerSQLiteFileURL = ServerApplicationSupportFolderURL.URLByAppendingPathComponent("data.sqlite")

public let ServerLastResourceIDByEntityNameFileURL = ServerApplicationSupportFolderURL.URLByAppendingPathComponent("lastResourceIDByEntityName.plist")

public let ServerSettingsFileURL = ServerApplicationSupportFolderURL.URLByAppendingPathComponent("serverSettings.plist")


