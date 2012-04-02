//
//  ConnectionLogicDelegate.h
//  PropPhone
//
//  Created by Chris Lavender on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class ConnectionLogic;

@protocol ConnectionLogicDelegate
- (void) connectionTerminated:(id)sender reason:(NSString*)reason;
- (void) isConnected:(BOOL)state;

@optional
- (void) processMessage:(id)message;
- (void) didResolveService:(NSNetService*)service;
- (void) displayHeartbeat:(UInt8)val;
- (void) displayNowItem:(NSString*)title;
- (void) didReceiveLoopStateMsg:(BOOL)state;
@end
