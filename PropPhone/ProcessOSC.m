//
//  ProcessOSC.m
//  PropPhone
//
//  Created by Chris Lavender on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProcessOSC.h"

#define OSC_VAL_BYTE_SWAP(val_ptr) memcpy(&u.int_val,val_ptr,4); u.int_val = htonl(u.int_val);

@implementation ProcessOSC

#define OSC_START mOSCOutBufferLength = 0;
#define OSC_END [self sendOSC];
#define OSC_ADD(msg,num_msg_bytes) memcpy(mOSCOutBuffer+mOSCOutBufferLength,msg,num_msg_bytes);mOSCOutBufferLength+=num_msg_bytes;

union {
    float	flt_val;
    int		int_val;
} u;


@synthesize delegate = _delegate;

- (id)init {
    return self;
}

- (void)dealloc {
    [super dealloc];
}

-(void)packOSCMsg:(const char*)osc_str:(int)osc_str_length {
    //printf("packOSCMsg:\n");
    char buf[128]; 
    memcpy(buf,osc_str,osc_str_length); 
    memcpy(buf+osc_str_length,",s\0\0",4);
	
    /*
	OSC_START
	OSC_ADD(buf,osc_str_length+4);
	OSC_END
     */
    
    //memcpy(mOSCOutBuffer,buf,osc_str_length+4);
    [self.delegate sendOSC:buf :osc_str_length+4];
}

-(void)packOSCMsgWithIntValue:(const char*)osc_str:(int)osc_str_length:(int)val {
    // printf("packOSCMsgWithIntValue:\n");
    char buf[128]; memcpy(buf,osc_str,osc_str_length); memcpy(buf+osc_str_length,",i\0\0",4);
	val = htonl(val);
	
	OSC_START
	OSC_ADD(buf,osc_str_length+4);
	OSC_ADD(&val,4);
	OSC_END
}

-(void)packOSCMsgWithString:(const char *)osc_str :(int)osc_str_length :(NSString*)msg {
    // printf("packOSCMsgWithIntValue:\n");
    const char *raw_msg = [msg UTF8String];
	int raw_msg_length = (strlen(raw_msg) / 4 + 1) * 4;
    
    char buf[128]; 
    memcpy(buf,osc_str,osc_str_length);
    memcpy(buf+osc_str_length,",s\0\0",4);
    
    char str_buf[128]; 
    memcpy(str_buf,raw_msg,raw_msg_length);
    
    OSC_START
	OSC_ADD(buf,osc_str_length+4);
	OSC_ADD(str_buf,raw_msg_length);
	OSC_END
}


- (void)parseOSC:(NSData*)raw {    
    
    /*
    NSString *content = [[[NSString alloc]  initWithBytes:[raw bytes]
                                                   length:[raw length] 
                                                 encoding: NSUTF8StringEncoding]autorelease];
    NSLog(@"recieve content: %@", content);
    */

    char inBuffer[1024];
    size_t inBufferLength = [raw length];
    
    [raw getBytes:inBuffer length:inBufferLength];
    
    ssize_t pos = 0;
    int msg_type = 0;
    int add_type = 0;
    
    while (pos < inBufferLength)
    {
        switch (msg_type)
        {
            case 0:
            {
                
#define	OSC_MSG_COMPARE(osc_add,add_type_val) if (strcmp(inBuffer,osc_add)==0) add_type = add_type_val;
                
                OSC_MSG_COMPARE("/prop/default",1)
                else OSC_MSG_COMPARE("/prop/play",2)
                    else OSC_MSG_COMPARE("/prop/pause",3)
                        else OSC_MSG_COMPARE("/prop/stop",4)
                            else OSC_MSG_COMPARE("/prop/led",5)
                                else OSC_MSG_COMPARE("/prop/loop",6)
                                    else OSC_MSG_COMPARE("/prop/playbutt",7)
                                        else OSC_MSG_COMPARE("/prop/stopbutt",8)
                                            else OSC_MSG_COMPARE("/prop/next", 9)
                                                else OSC_MSG_COMPARE("/prop/prev", 10)
                                                    else OSC_MSG_COMPARE("/prop/nowplay", 11)
                                    //NSLog(@"add_type %d", add_type);
                                break;
            }
            case 1:
            {
                switch (add_type)
                {
                    case 1:{
                        //printf("DEFAULT!\n");
                        break;
                    }
					case 2:{
                        //printf("PLAY!\n");
                        [self.delegate receivedTransportMessage:@"play"];
                        break;
                    }
                    case 3:{
                        //printf("PAUSE!\n");
                        [self.delegate receivedTransportMessage:@"pause"];
                        break;
                    }
                    case 4:{
                        //printf("STOP!\n");
                        [self.delegate receivedTransportMessage:@"stop"];
                        break;
                    }
                    case 7:{
                        //printf("PLAYBUTT!\n");
                        [self.delegate receivedTransportMessage:@"playbutt"];
                        break;
                    }
                    case 8:{
                        //printf("STOPBUTT!\n");
                        [self.delegate receivedTransportMessage:@"stopbutt"];
                        break;
                    }
                    case 9:{
                        //printf("NEXTBUTT!\n");
                        [self.delegate receivedTransportMessage:@"nextbutt"];
                        break;
                    }
                    case 10:{
                        //printf("PREVBUTT!\n");
                        [self.delegate receivedTransportMessage:@"prevbutt"];
                        break;
                    }
                        
                }
                break;
            }
                
            case 2:
            {
                switch (add_type)
                {
                    case 5:
                    {
                        OSC_VAL_BYTE_SWAP(inBuffer+pos)
                        //printf("LED %d\n",u.int_val);
                        [self.delegate receivedHeartbeat:u.int_val];
                        break;
                    }
					case 6:
					{
                        OSC_VAL_BYTE_SWAP(inBuffer+pos)
                        //printf("LOOP %d\n",u.int_val);
                        [self.delegate receivedLoopMsg:u.int_val];
                        break;
                    }
                    case 11:
					{
                        NSString *nowItem = [NSString stringWithUTF8String:inBuffer+pos];
                        NSLog(@"received /prop/nowItem:%@",nowItem);                        
                        //printf("nowItem received\n");
                        [self.delegate receivedTransportMessage:nowItem];
                        //[nowItem release];
                        break;
                    }

                }
                break;
            }
            default:
                break;
        }
        
        //NSLog(@"msg_type %d", msg_type);
        //const char* msg_type_str = "";
        switch (msg_type)
        {
            case 0: /*msg_type_str = "OSC Address Pattern";*/ msg_type = 1; break;
            case 1: /*msg_type_str = "OSC Type Tags";*/ msg_type = 2; break;
            default: /*msg_type_str = "OSC Data";*/ break;
        }
        //printf("%s: %s\n",msg_type_str,inBuffer+pos);
        pos += ((strlen(inBuffer+pos) / 4) + 1)* 4;
        //printf("pos:%ld\n", pos);
    }
}

- (void)sendOSC {
    
    //printf("mOSCOutBuffer:%s\n", mOSCOutBuffer);
    [self.delegate sendOSC:mOSCOutBuffer :mOSCOutBufferLength];
}
@end
