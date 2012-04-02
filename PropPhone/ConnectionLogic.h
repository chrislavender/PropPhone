//
//  ConnectionLogic.h
//  PropPhone
//
//  Created by Chris Lavender on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConnectionLogicDelegate.h"
#import "Connection.h"
#import "ConnectionDelegate.h"

@interface ConnectionLogic : NSObject <ConnectionDelegate>{
    
}

@property (unsafe_unretained, nonatomic) id<ConnectionLogicDelegate> delegate;

@property (strong, nonatomic) NSDictionary *messageDictionary;
@property (nonatomic) BOOL isConnected;

- (BOOL)start;
- (void)stop;
//- (void)broadcastChatMessage:(NSString*)message fromUser:(NSString*)name;

// messageType = OSC style string and object is the data object to send
- (void)sendMessage:(NSString*)messageType:(id)object;

+ (NSDictionary*)messageDictionary;

@end
