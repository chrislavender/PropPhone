//
//  ActionViewController.h
//  propPractice
//
//  Created by Chris Lavender on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomControl.h"
@protocol ActionViewControllerDelegate;

@interface ActionViewController : UIViewController <CustomControlDelegate> {
    
    IBOutlet  UIView   *standbyView;
    IBOutlet  UIView   *incomingCallView;
    IBOutlet  UIView   *endCallview;
}

@property (unsafe_unretained, nonatomic) id <ActionViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString  *transportState;

@property (strong, nonatomic) IBOutlet UIButton     *lowerLock;
@property (strong, nonatomic) IBOutlet UIButton     *upperLock;
@property (strong, nonatomic) IBOutlet UIImageView  *unlockImage;
@property (strong, nonatomic) IBOutlet CustomControl*instructionView;

- (IBAction)answerCall;
- (IBAction)endCall;
- (IBAction)unlock:(UIButton*)sender;

- (void)done;
@end


@protocol ActionViewControllerDelegate
- (void)actionViewControllerDidFinish:(ActionViewController *)controller;
- (void)userRespondedFromActionView:(ActionViewController *)controller withAction:(NSString*)action;

@end
