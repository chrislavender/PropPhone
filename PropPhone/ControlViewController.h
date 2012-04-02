//
//  ControlViewController.h
//  Prop Phone
//
//  Created by Chris Lavender on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerBrowser.h"
#import "ServerBrowserDelegate.h"

#import "ControlClient.h"
#import "ConnectionLogicDelegate.h"

#import "SoundboardViewController.h"

@class ControlViewController;

@protocol ControlViewControllerDelegate
- (void)killControl:(ControlViewController*)requestor;
@end

@interface ControlViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ServerBrowserDelegate, ConnectionLogicDelegate, SoundboardViewControllerDelegate>
{
    ServerBrowser   *serverBrowser;
    NSArray         *disconnectedToolbar;
    NSArray         *connectedToolbar;
    
    IBOutlet UITableView    *serverList;
}

@property   (unsafe_unretained, nonatomic)  id<ControlViewControllerDelegate> delegate;

@property   (strong, nonatomic)             ControlClient   *clientConnection;
@property   (strong, nonatomic, readonly)   NSArray         *soundboardList;

#pragma mark - IBOutlets
@property   (strong, nonatomic) IBOutlet    UIView      *bv;
@property   (strong, nonatomic) IBOutlet    UIView      *controlsView;
@property   (strong, nonatomic) IBOutlet    UIButton    *led;
@property   (strong, nonatomic) IBOutlet    UILabel     *status;
@property   (strong, nonatomic) IBOutlet    UILabel     *cueTitleLabel;
@property   (strong, nonatomic) IBOutlet    UILabel     *cueItemLabel;
@property   (strong, nonatomic) IBOutlet    UILabel     *introLabel;
@property   (strong, nonatomic) IBOutlet    UIButton    *loopButton;
@property   (strong, nonatomic) IBOutlet    UIButton    *playButton;
@property   (strong, nonatomic) IBOutlet    UIButton    *pauseButton;
@property   (strong, nonatomic) IBOutlet    UIToolbar   *toolbar;


#pragma mark - Browser IBOutlets
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView  *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel                  *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel                  *statusLabel;

#pragma mark - IBActions
- (IBAction)    done;
- (IBAction)    showBrowser;
- (IBAction)    showSoundboard;
- (IBAction)    dismissBrowser;
- (IBAction)    mediaTransport:         (UIButton*)sender;
- (IBAction)    playDefaultSound:       (UIButton*)sender;
- (IBAction)    sendLoopPlaybackToggle;

@end
