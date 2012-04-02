//
//  PropServer.m
//  PropPhone
//
//  Created by Chris Lavender on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PropServer.h"
#import "Connection.h"
#import "AppConfig.h"


// Private properties
@interface PropServer ()
@property(strong, nonatomic) Server *server;
// @property(nonatomic,retain) NSMutableSet *clients;
- (BOOL)start;
- (void)stop;

@end


@implementation PropServer

@synthesize currentConnection = _currentConnection;
@synthesize server;
// @synthesize clients;
@synthesize mHeartbeatTimer;

// Initialization
- (id)init {
    // clients = [[NSMutableSet alloc] init];
    return self;
}


// Cleanup

// Start the server and announce self
- (BOOL)start {
    
    //printf("PropServer START\n");
    
    self.isConnected = NO;
    
    // Create new instance of the server and start it up
    server = [[Server alloc] init];
    
    // We will be processing server events
    server.delegate = self;
    
    // Try to start it up
    if ( ! [server start] ) {
        // printf("PropServer.m [server start] FAILED\n");
        self.server = nil;
        return NO;
    }
    
    if (self.messageDictionary==nil) {
        self.messageDictionary = [ConnectionLogic messageDictionary];
    }
    // printf("PropServer.m [server start] SUCCEEDED\n");
    return YES;
}


// Stop everything
- (void)stop {
    
    // Destroy server
    [server stop];
    
    // Close & release all connections
    // [clients makeObjectsPerformSelector:@selector(close)];
    [self.currentConnection performSelector:@selector(close)];
}
/*
- (void) broadcastChatMessage:(NSString *)message fromUser:(NSString *)name {
    
    NSDictionary* packet = [NSDictionary dictionaryWithObjectsAndKeys:message, @"message", name, @"from", nil];
    // Send it out
    [self.currentConnection sendNetworkPacket:packet];
}
*/
- (void)sendMessage:(NSString *)messageType :(id)object {
    // Create network packet to be sent to all clients
    NSDictionary* packet = [NSDictionary dictionaryWithObjectsAndKeys:messageType,@"messageType",object,@"object", nil];
    
    // Send it out
    [self.currentConnection sendNetworkPacket:packet];
}

#pragma mark-
#pragma mark ServerDelegate Method Implementations

// Server has failed. Stop the world.
- (void) serverFailed:(Server*)server reason:(NSString*)reason {
    // Stop everything and let our delegate know
    [self stop];
    [self.delegate connectionTerminated:self reason:reason];
}

- (void) serverDidPublish {
    //[serverBrowser stop];
    //printf("Server Published\n");
}

- (void)sendOSCHeartbeat {
    mHeartbeat = mHeartbeat == 0 ? 1 : mHeartbeat == 1 ? 0: -1;

    NSNumber *val = [NSNumber numberWithInt:mHeartbeat];
    [self sendMessage:@"/prop/led" :val];
    [self.delegate displayHeartbeat:mHeartbeat];
}

// New client connected to our server. Add it.
- (void) handleNewConnection:(Connection*)connection {
    
    self.currentConnection = connection;
    
    // Delegate everything to us
    connection.delegate = self;
    
    // Add to our list of clients
    // [clients addObject:connection];
    
    mHeartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:.5 
                                                       target:self 
                                                     selector:@selector(sendOSCHeartbeat) 
                                                     userInfo:nil 
                                                      repeats:YES];
    self.isConnected = YES;
}

#pragma mark-
#pragma mark ConnectionDelegate Method Implementations

// We won't be initiating connections, so this is not important
- (void)connectionAttemptFailed:(Connection*)connection {
    // printf("sorry... connection attempt failed\n");
}


// One of the clients disconnected, remove it from our list
- (void)connectionTerminated:(Connection*)connection {
    self.isConnected = NO;
    // [clients removeObject:connection];
    [self.delegate connectionTerminated:self reason:@"The control device has terminated it's connection."];
}

- (void) receivedNetworkPacket:(NSDictionary *)message viaConnection:(Connection *)connection {    
    NSString *msgType = [message objectForKey:@"messageType"];
    if (!self.isConnected) self.isConnected = YES;
    
    // NSLog(@"messageType:%@",msgType);

    int type = [[self.messageDictionary objectForKey:msgType]intValue];
    
    switch (type) {
        case 1:
            // @"/prop/play"
            [self.delegate processMessage:@"play"];
            break;
        case 2:
            // @"/prop/stop"
            [self.delegate processMessage:@"stop"];
            break;
        case 3:
            //@"/prop/pause"
            [self.delegate processMessage:@"pause"];
            break;
        case 4:
            // @"/prop/next"
             [self.delegate processMessage:@"next"];
            break;
        case 5:
            // @"/prop/prev"
            [self.delegate processMessage:@"prev"];
            break;
        case 6:
            // @"/prop/loop"
            if ([[message objectForKey:@"object"] isKindOfClass:[NSNumber class]]) {
                [self.delegate didReceiveLoopStateMsg:[[message objectForKey:@"object"]boolValue]]; 
            }
            break;
        case 12:
            // @"/prop/trackplay" 
            if ([[message objectForKey:@"object"] isKindOfClass:[NSIndexPath class]]) {
                [self.delegate processMessage:[message objectForKey:@"object"]];
                [self.delegate processMessage:@"play"];
            }
            break;
        case 13:
            // @"/prop/trackstop" 
            [self.delegate processMessage:@"stop"]; 
            break;
        case 14:
            // NSLog(@"/prop/default");
            if ([[message objectForKey:@"object"] isKindOfClass:[NSNumber class]]) {
                [self.delegate processMessage:[message objectForKey:@"object"]]; 
            } 
            break;
            
        default:
            break;
    }
}


- (void)didResolveService:(NSNetService *)service {
    [self.delegate didResolveService:service];
}
@end
