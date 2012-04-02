//
//  ProcessOSCDelegate.h
//  PropPhone
//
//  Created by Chris Lavender on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class ProcessOSCDelegate;

@protocol ProcessOSCDelegate
@optional
- (void)sendOSC:(const char*)mOSCOutBuffer:(int)mOSCOutBufferLength;
- (void)receivedTransportMessage:(NSString *)state;
- (void)receivedHeartbeat:(UInt8)val;
- (void)receivedLoopMsg:(UInt8)val;
@end
