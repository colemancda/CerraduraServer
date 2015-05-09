//
//  main.m
//  CerraduraServerDaemon
//
//  Created by Alsey Coleman Miller on 4/11/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreCerraduraServer;

int main(int argc, const char * argv[]) {
    
    @autoreleasepool {

        NSLog(@"Starting Cerradura Server Daemon...");
        
        NSError *error = [[ServerManager sharedManager] start];
        
        if (error != nil) {
            
            NSLog(@"Could not start server on port %lu (%@)", [ServerManager sharedManager].serverPort, error.localizedDescription);
            
            return 1;
        }
        
        NSLog(@"Started server on port %lu", [ServerManager sharedManager].serverPort);
    }
    
    [[NSRunLoop currentRunLoop] run];
    
    return 0;
}
