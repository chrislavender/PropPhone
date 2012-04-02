//
//  ControlClient.m
//  PropPhone
//
//  Created by Chris Lavender on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ControlClient.h"
#import <MediaPlayer/MediaPlayer.h>

// Private properties
@interface ControlClient ()
@end


@implementation ControlClient

@synthesize connection;

// Setup connection but don't connect yet
- (id)initWithHost:(NSString*)host andPort:(int)port {
    connection = [[Connection alloc] initWithHostAddress:host andPort:port];
    return self;
}


// Initialize and connect to a net service
- (id)initWithNetService:(NSNetService*)netService {
    connection = [[Connection alloc] initWithNetService:netService];
    return self;
}


// Cleanup


// Start everything up, connect to server
- (BOOL)start {
    
    if ( connection == nil ) {
        return NO;
    }
    
    // We are the delegate
    connection.delegate = self;
    
    if (self.messageDictionary==nil) {
        self.messageDictionary = [ConnectionLogic messageDictionary];
    }
    
    return [connection connect];
}


// Stop everything, disconnect from server
- (void)stop {
    
    if ( connection == nil ) {
        return;
    }
    [connection close];
    self.connection = nil;
}

/*
// Send chat message to the server
- (void)broadcastChatMessage:(NSString*)message fromUser:(NSString*)name {
    // Create network packet to be sent to all clients
    NSDictionary* packet = [NSDictionary dictionaryWithObjectsAndKeys:message, @"message", name, @"from", nil];
    
    // Send it out
    [connection sendNetworkPacket:packet];
}
*/

- (void)sendMessage:(NSString *)messageType :(id)object {
    // Create network packet to be sent to all clients
    NSDictionary* packet = [NSDictionary dictionaryWithObjectsAndKeys:messageType,@"messageType",object,@"object", nil];
    
    // Send it out
    [connection sendNetworkPacket:packet];
}

- (void)receivedNetworkPacket:(NSDictionary *)message viaConnection:(Connection *)connection {
    
    NSString *msgType = [message objectForKey:@"messageType"];
    if (!self.isConnected) self.isConnected = YES;

    int type = [[self.messageDictionary objectForKey:msgType]intValue];
    
    switch (type) {
        case 0:
            // NSLog(@"/prop/led");
            [self.delegate displayHeartbeat:[[message objectForKey:@"object"]intValue]];
            break;
        case 7:
            // NSLog(@"/prop/playbutt");
            [self.delegate processMessage:@"playbutt"];
            break;
        case 8:
            // NSLog(@"/prop/stopbutt");
            [self.delegate processMessage:@"stopbutt"];
            break;
        case 9:
            // @"/prop/nowplay"
            if ([[message objectForKey:@"object"] isKindOfClass:[NSString class]]) {
                [self.delegate processMessage:[message objectForKey:@"object"]]; 
            }
            break;
        case 10:
            // @"/prop/loopbutt"
            if ([[message objectForKey:@"object"] isKindOfClass:[NSNumber class]]) {
                [self.delegate didReceiveLoopStateMsg:[[message objectForKey:@"object"]boolValue]]; 
            }
            break;
        case 11:
            // @"/prop/cuelist
            if ([[message objectForKey:@"object"] isKindOfClass:[NSArray class]]) {
                // printf("NSArray cuelist received\n");
                [self.delegate processMessage:[message objectForKey:@"object"]]; 
            }
            break;
        case 15:
            // NSLog(@"/prop/pausebutt");
            [self.delegate processMessage:@"pausebutt"];
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark ConnectionDelegate Method Implementations

- (void)connectionAttemptFailed:(Connection*)connection {
    if (self.isConnected) self.isConnected = NO;
    [self stop];
    [self.delegate connectionTerminated:self reason:@"Unable to connect to the selected device. Please check your network settings and try again."];
}

- (void)connectionTerminated:(Connection*)connection {
    if (self.isConnected) self.isConnected = NO;
    [self stop];
    [self.delegate connectionTerminated:self reason:@"Prop device has disconnected."];
}

- (void) didResolveService:(NSNetService *)service {
    [self.delegate didResolveService:service];
}

@end