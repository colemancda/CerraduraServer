//
//  AuthenticationManager.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 4/28/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData
import CoreCerradura

/** Handles the authentication for the NetworkObjects API consumers. */
public final class AuthenticationManager {
    
    // MARK: - Properties
    
    /** The amount of time (in seconds) the recieved authorization headers are valid. */
    public let authorizationHeaderTimeout: UInt = 90
    
    // MARK: - Private Properties
    
    private let httpDateFormatter: NSDateFormatter = {
       
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"
        
        return dateFormatter
    }()
    
    // MARK: - Methods
    
    /** Verifies the authorization header as valid and derives the authenticated entity. */
    public func verifyAuthorizationHeader<T: NSManagedObject>(authorizationHeader: String, dateHeader: String, contentMD5Header: String, managedObjectContext: NSManagedObjectContext) -> T? {
        
        // get identifier...
        
        let headerData = (authorizationHeader as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        
        let headerJSONObject = NSJSONSerialization.JSONObjectWithData(headerData!, options: NSJSONReadingOptions.allZeros, error: nil) as? [String: String]
        
        if headerJSONObject == nil || headerJSONObject?.count != 1 {
            
            return nil
        }
        
        let identifer = headerJSONObject!.keys.first!
        
        let signedKey = headerJSONObject!.values.first!
        
        // get date and content MD5
        
        let date = self.httpDateFormatter.dateFromString(dateHeader)
        
        if date == nil {
            
            return nil
        }
        
        
        
    }
    
}