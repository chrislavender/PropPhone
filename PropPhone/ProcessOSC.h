//
//  ProcessOSC.h
//  PropPhone
//
//  Created by Chris Lavender on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProcessOSCDelegate.h"

@interface ProcessOSC : NSObject {
    
    char			mOSCOutBuffer[1024];
	int             mOSCOutBufferLength;

}
@property(nonatomic,assign) id<ProcessOSCDelegate> delegate;

- (void)packOSCMsgWithString:(const char*)osc_str:(int)osc_str_length:(NSString*)msg;
- (void)packOSCMsgWithIntValue:(const char*)osc_str:(int)osc_str_length:(int)val;
- (void)packOSCMsg:(const char*)osc_str:(int)osc_str_length;

- (void)parseOSC:(NSData*)parseOSC;

- (void)sendOSC;
@end
