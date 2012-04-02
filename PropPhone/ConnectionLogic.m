//
//  ConnectionLogic.m
//  PropPhone
//
//  Created by Chris Lavender on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConnectionLogic.h"

@implementation ConnectionLogic

@synthesize delegate = _delegate;
@synthesize isConnected = _isConnected;
@synthesize messageDictionary=_messageDictionary;

- (void)setIsConnected:(BOOL)isConnected {
    _isConnected = isConnected;
    [self.delegate isConnected:isConnected];
}

// Cleanup


// "Abstract" methods
- (BOOL)start {
    // Crude way to emulate "abstract" class
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (void)stop {
    // Crude way to emulate "abstract" class
    [self doesNotRecognizeSelector:_cmd];
}
/*
- (void)broadcastChatMessage:(NSString*)message fromUser:(NSString*)name {
    // Crude way to emulate "abstract" class
    [self doesNotRecognizeSelector:_cmd];
}
*/

- (void)sendMessage:(NSString *)messageType :(id)object {
    [self doesNotRecognizeSelector:_cmd];
}

+ (NSDictionary*)messageDictionary {
    NSDictionary*messageDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"0" , @"/prop/led",        //from prop to controller
                                @"1" , @"/prop/play",       //from controller to prop
                                @"2" , @"/prop/stop",       //from controller to prop
                                @"3" , @"/prop/pause",      //from controller to prop
                                @"4" , @"/prop/next",       //from controller to prop
                                @"5" , @"/prop/prev",       //from controller to prop
                                @"6" , @"/prop/loop",       //from controller to prop
                                @"7" , @"/prop/playbutt",   //from prop to controller
                                @"8" , @"/prop/stopbutt",   //from prop to controller
                                @"9" , @"/prop/nowplay",    //from prop to controller
                                @"10", @"/prop/loopbutt",   //from prop to controller
                                @"11", @"/prop/cuelist",    //from prop to controller
                                @"12", @"/prop/trackplay",  //from controller to prop 
                                @"13", @"/prop/trackstop",  //from controller to prop
                                @"14", @"/prop/default",    //from controller to prop but not yet implemented
                                @"15", @"/prop/pausebutt",  //from prop to controller
                                nil];
    return messageDict;
}

#pragma mark-
#pragma mark ConnectionDelegate Method Implementations

- (void)receivedNetworkPacket:(NSDictionary *)message viaConnection:(Connection *)connection {
    NSLog(@"receivedNetworkPacket called in ConnectionLogic.m");
}

- (void)connectionAttemptFailed:(Connection*)connection {
    NSLog(@"connectionAttemptFailed called in ConnectionLogic.m");
}


- (void)connectionTerminated:(Connection*)connection {
    NSLog(@"connectionTerminated called in ConnectionLogic.m");
}

@end
