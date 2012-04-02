//
//  PropViewController.h
//  Prop Phone
//
//  Created by Chris Lavender on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ActionViewController.h"
#import "GDMediaPlayer.h"
#import "PropServer.h"
#import "ConnectionLogicDelegate.h"
#import "CueListViewController.h"

@class PropViewController;

@protocol PropViewControllerDelegate
- (void)killProp:(PropViewController*)requestor;
@end

@interface PropViewController : UIViewController <ActionViewControllerDelegate, ConnectionLogicDelegate, GDMediaPlayerDelegate,UIPickerViewDelegate, CueListViewControllerDelegate>
{    
    PropServer              *mServer;
    NSString                *mTransportState;
    UIView                  *timerSetView;
}
@property (unsafe_unretained, nonatomic) id <PropViewControllerDelegate> delegate;

@property (strong, nonatomic, readonly) GDMediaPlayer           *mediaPlayer;
@property (strong, nonatomic)           MPMediaItemCollection   *mediaCollection;

@property (strong, nonatomic) IBOutlet UIView           *timerSetView;
@property (strong, nonatomic) IBOutlet UIButton         *playButton;
@property (strong, nonatomic) IBOutlet UIButton         *pauseButton;
@property (strong, nonatomic) IBOutlet UIButton         *stopButton;
@property (strong, nonatomic) IBOutlet UIButton         *loopButton;
@property (strong, nonatomic) IBOutlet UIButton         *timerButton;
@property (strong, nonatomic) IBOutlet UIButton         *phoneButton;
@property (strong, nonatomic) IBOutlet UIButton         *ipodButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem  *timerSaveButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem  *timerCancelButton;
@property (strong, nonatomic) IBOutlet UIButton         *led;
@property (strong, nonatomic) IBOutlet UILabel          *status;
@property (strong, nonatomic) IBOutlet UILabel          *countdownLable;
@property (strong, nonatomic) IBOutlet UIPickerView     *timerScrollView;


- (IBAction)    done;
- (IBAction)    mediaTransport:     (id)sender;
- (IBAction)    propViewPlayButton: (UIButton*)sender;
- (IBAction)    showCueList:        (UIButton*)sender;
- (IBAction)    setCountdownState:  (UIBarButtonItem*)sender;
- (IBAction)    loopPlaybackToggle;
- (IBAction)    selectDefaultSound;
- (IBAction)    showTimerSetView;
- (IBAction)    dismissTimerSetView;

@end
