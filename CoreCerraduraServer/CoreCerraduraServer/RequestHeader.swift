//
//  RequestHeader.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 5/27/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation

/** Standard HTTP headers. */
public enum RequestHeader: String {
    
    case Date = "Date"
    case Authorization = "Authorization"
}

/** HTTP Headers used with requests from lock devices. */
public enum LockRequestHeader: String {
    
    case FirmwareBuild = "x-cerradura-firmware"
    case SoftwareVersion = "x-cerradura-version"
}