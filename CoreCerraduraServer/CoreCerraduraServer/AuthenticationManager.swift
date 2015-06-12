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
import ExSwift

/** Handles the authentication for the NetworkObjects API consumers. */
public final class AuthenticationManager {
    
    // MARK: - Properties
    
    public let authorizationHeaderTimeout = Setting.AuthorizationHeaderTimeout.staticValue
    
    // MARK: - Private Properties
    
    private let httpDateFormatter: NSDateFormatter = {
       
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"
        
        return dateFormatter
    }()
    
    // MARK: - Methods
    
    /// Verifies the authorization header as valid and derives the authenticated entity. Does not allow archived entities to authenticate.
    ///
    /// :param: authorizationHeader The token used for authorization.
    /// :param: identifierKey The key of the identifier for the authenticating entity.
    /// :param: secretKey The key of the secret for the authenticating entity.
    /// :param: entityName Name of the entity authenticating.
    /// :param: authenticationContext The context of the authentication.
    /// :param: managedObjectContext The managed object context used to fetch the authenticating entity.
    public func authenticateWithHeader(header: String, identifierKey: String, secretKey: String, entityName: String, authenticationContext: AuthenticationContext, managedObjectContext: NSManagedObjectContext) -> (NSError?, NSManagedObject?) {
        
        // get identifier...
        
        let headerData = (header as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        
        let headerJSONObject = NSJSONSerialization.JSONObjectWithData(headerData!, options: NSJSONReadingOptions.allZeros, error: nil) as? [String: String]
        
        if headerJSONObject == nil || headerJSONObject?.count != 1 {
            
            return (nil, nil)
        }
        
        let identifier = headerJSONObject!.keys.first!
        
        let signature = headerJSONObject!.values.first!
        
        // get date
        
        let date = self.httpDateFormatter.dateFromString(authenticationContext.dateString)
        
        if date == nil {
            
            return (nil, nil)
        }
        
        // date cannot be newer than current date
        
        if date! < NSDate() {
            
            return (nil, nil)
        }
        
        // token expired
        
        if NSDate(timeInterval: self.authorizationHeaderTimeout, sinceDate: date!) < NSDate()  {
            
            return (nil, nil)
        }
        
        // get user
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        
        fetchRequest.predicate = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: identifierKey),
            rightExpression: NSExpression(forConstantValue: identifier),
            modifier: NSComparisonPredicateModifier.DirectPredicateModifier,
            type: NSPredicateOperatorType.EqualToPredicateOperatorType,
            options: NSComparisonPredicateOptions.CaseInsensitivePredicateOption)
        
        fetchRequest.fetchLimit = 1
        
        var error: NSError?
        
        var result: [NSManagedObject]?
        
        managedObjectContext.performBlockAndWait({ () -> Void in
            
            result = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
            
            return
        })
        
        if error != nil {
            
            return (error!, nil)
        }
        
        let authenticatingEntity: NSManagedObject? = result!.first
        
        if authenticatingEntity == nil {
            
            return (nil, nil)
        }
        
        // check if entity is archived
        if let archivable = authenticatingEntity as? Archivable {
            
            var archived: Bool!
            
            managedObjectContext.performBlockAndWait({ () -> Void in
                
                archived = archivable.archived.boolValue
                
                return
            })
            
            if archived == true {
                
                return (nil, nil)
            }
        }
        
        let secret: String = {
            
            var secret: String!
            
            managedObjectContext.performBlockAndWait({ () -> Void in
                
                secret = authenticatingEntity!.valueForKey(secretKey) as! String
            })
            
            return secret
        }()
        
        // create signature...
        
        let serverSignature = GenerateAuthenticationToken(identifier, secret, authenticationContext)
        
        if serverSignature != header {
            
            return (nil, nil)
        }
        
        return (nil, authenticatingEntity!)
    }
}