//
//  ControlViewController.m
//  Prop Phone
//
//  Created by Chris Lavender on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ControlViewController.h"
#import "ConnectionLogic.h"
#import "AppConfig.h"


@interface ControlViewController() 
{    
    BOOL loopingOn;
    BOOL playingOrPaused;
}
@property (strong, nonatomic,readwrite)          NSArray     *soundboardList;
@property (strong, nonatomic)    SoundboardViewController    *sbViewCntrl;
@end

@implementation ControlViewController

@synthesize delegate=           _delegate;
@synthesize sbViewCntrl=        _sbViewCntrl; // View controller for the soundboard
@synthesize soundboardList=     _soundboardList; // an NSArray of NSStrings (cue titles)
@synthesize clientConnection=   _clientConnection;

@synthesize bv; // browser view
@synthesize controlsView; //loaded from xibs

@synthesize led=            _led; //hearbeat
@synthesize status=         _status; //network status
@synthesize cueItemLabel=   _cueItemLabel; //the title of the cue item
@synthesize cueTitleLabel=  _cueTitleLabel; // the static label for the cue item field
@synthesize introLabel=     _introLabel; // instructions when network is off
@synthesize loopButton=     _loopButton;
@synthesize playButton=     _playButton;
@synthesize pauseButton=    _pauseButton;
@synthesize toolbar=        _toolbar;

@synthesize activityIndicator=  _activityIndicator;
@synthesize nameLabel=          _nameLabel; // name of connected prop device
@synthesize statusLabel=        _statusLabel; //title lable for status field

- (BOOL)connected {
    BOOL result;
    if (self.clientConnection == nil) result = NO;
    else result = YES;
    return result;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.view bringSubviewToFront:self.introLabel];
        [self.view sendSubviewToBack:self.controlsView];
        
        
        
        UIBarButtonItem *main = [[UIBarButtonItem alloc]initWithTitle:@"Main Screen" 
                                                                style:UIBarButtonItemStyleBordered 
                                                               target:self 
                                                               action:@selector(done)];
        UIBarButtonItem *sound = [[UIBarButtonItem alloc]initWithTitle:@"Soundboard" 
                                                                style:UIBarButtonItemStyleBordered 
                                                               target:self 
                                                               action:@selector(showSoundboard)];
        UIBarButtonItem *flex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                             target:self 
                                                                             action:nil];
        
        disconnectedToolbar = [[NSArray alloc]initWithObjects:main, nil];
        connectedToolbar    = [[NSArray alloc]initWithObjects:main,flex,sound, nil];
        
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark-
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.status.text = @"Not Connected.";
    self.introLabel.text = @"Connect via the socket icon while another Prop Phone device is in prop mode.";
}

- (void) viewWillAppear:(BOOL)animated
{
    // for some reason self.toolbar setItems: would not load in viewDidLoad
    if ([self connected]) {
        [self.toolbar setItems:connectedToolbar animated:NO];
    }
    else [self.toolbar setItems:disconnectedToolbar animated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.bv                 =nil;
    self.led                =nil;
    self.status             =nil;
    self.nameLabel          =nil;
    self.introLabel         =nil;
    self.playButton         =nil;
    self.pauseButton        =nil;
    self.loopButton         =nil;
    self.statusLabel        =nil;
    self.controlsView       =nil;
    self.cueItemLabel       =nil;
    self.controlsView       =nil;
    self.cueTitleLabel      =nil;
    self.toolbar            =nil;
    self.activityIndicator  =nil;
   }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark-
#pragma mark IBActions

- (IBAction)showBrowser
{    
    [[NSBundle mainBundle] loadNibNamed:@"BrowserView" owner:self options:nil];

    //alloc/init the browser
    serverBrowser = [[ServerBrowser alloc] init];
    serverBrowser.delegate = self;
    self.nameLabel.text = [AppConfig getInstance].name;
    [self updateServerList];
    
    //start the browser
    [serverBrowser start];
    [self.activityIndicator startAnimating];
    self.statusLabel.text = @"Searching for a device to control...";
    
    self.bv.frame = CGRectMake(0, 
                               480, 
                               self.bv.bounds.size.width, 
                               self.bv.bounds.size.height);
    
    //show the browser view (off screen)
    [self.view addSubview:self.bv];

    [UIView animateWithDuration:.5 
                     animations:^{
                         self.bv.frame = CGRectMake(0, 
                                                    480 - self.bv.bounds.size.height, 
                                                    self.bv.bounds.size.width, 
                                                    self.bv.bounds.size.height);
                     } 
                     completion:NULL];

}

- (IBAction)dismissBrowser {
    
    [UIView animateWithDuration:.5 
                     animations:^{
                         self.bv.frame = CGRectMake(0, 
                                                    480, 
                                                    self.bv.bounds.size.width, 
                                                    self.bv.bounds.size.height);
                     } 
                     completion:^(BOOL finished){
                         [self.bv removeFromSuperview];
                         [serverBrowser stop];
                         [self.activityIndicator stopAnimating];
                         self.bv = nil;
                         if ([self connected]) {
                             [self.view bringSubviewToFront:self.controlsView];
                             [self.view sendSubviewToBack:self.introLabel];
                                 
                             CATransition *animation = [CATransition animation];
                             [animation setDuration:1.0];
                             [animation setType:kCATransitionFade];    
                             [self.view.layer addAnimation:animation forKey:nil];
                         }
                         else {
                             [self.view sendSubviewToBack:self.controlsView];
                             [self.view bringSubviewToFront:self.introLabel];
                                 
                             CATransition *animation = [CATransition animation];
                             [animation setDuration:1.0];
                             [animation setType:kCATransitionFade];    
                             [self.view.layer addAnimation:animation forKey:nil];
                         }
                     }];
}

- (IBAction)showSoundboard; {
    SoundboardViewController*soundboardController = 
        [[SoundboardViewController alloc]initWithNibName:@"SoundboardViewController" 
                                                  bundle:nil];
    soundboardController.delegate = self;
    soundboardController.soundboardList = self.soundboardList;
    
    if (playingOrPaused)soundboardController.currentCueTitle = self.cueItemLabel.text;
    else soundboardController.currentCueTitle = nil;
    
    self.sbViewCntrl = soundboardController; 
    
    [self presentModalViewController:soundboardController animated:YES];
    
    
    if ([self.cueItemLabel.text isEqualToString:@"Default Ringer"]) {
        // send a message to the prop to turn iTunes playback on
        [self.clientConnection sendMessage:@"/prop/default" :[NSNumber numberWithBool:YES]];
    }
}

- (IBAction)done
{
    if (self.clientConnection != nil) { 
        // printf("ControlViewController.clientConnection stopped?\n");
        [self.clientConnection stop];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    [self.delegate killControl:self];
}

- (IBAction)mediaTransport:(UIButton*)sender {
    
    /*const char *msg = [sender.titleLabel.text cStringUsingEncoding:NSASCIIStringEncoding];
     [(Prop_PhoneAppDelegate*) [[UIApplication sharedApplication] delegate] sendOSCMsg:msg :sizeof(msg)];*/
    
    NSString *transportAction = sender.titleLabel.text;
    
    if ([transportAction isEqualToString:@"play"]) {
        //[self.clientConnection.connection.processOSC packOSCMsg:"/prop/play\0\0":12];
        [self.clientConnection sendMessage:@"/prop/play" :nil];
    }
    else if ([transportAction isEqualToString:@"pause"]) {
        //[self.clientConnection.connection.processOSC packOSCMsg:"/prop/pause\0":12];
        [self.clientConnection sendMessage:@"/prop/pause" :nil];
    }
    else if ([transportAction isEqualToString:@"stop"]) {
        //[self.clientConnection.connection.processOSC packOSCMsg:"/prop/stop\0\0":12];
        [self.clientConnection sendMessage:@"/prop/stop" :nil];
    }
    else if ([transportAction isEqualToString:@"next"]) {
        //[self.clientConnection.connection.processOSC packOSCMsg:"/prop/next\0\0":12];
        [self.clientConnection sendMessage:@"/prop/next" :nil];
    }
    else if ([transportAction isEqualToString:@"prev"]) {
        //[self.clientConnection.connection.processOSC packOSCMsg:"/prop/prev\0\0":12];
        [self.clientConnection sendMessage:@"/prop/prev" :nil];
    }
}

- (IBAction)playDefaultSound:(UIButton*)sender {
    
    NSString *transportAction = sender.titleLabel.text;
    
    if ([transportAction isEqualToString:@"default"]) {
        //[self.clientConnection.connection.processOSC packOSCMsg:"/prop/default\0\0\0":16];
        [self.clientConnection sendMessage:@"/prop/default" :nil];
    }
}

- (IBAction)sendLoopPlaybackToggle {
    
    if (!loopingOn) {
        [self.loopButton setImage:[UIImage imageNamed:@"loop_default2.png"] forState:UIControlStateNormal];
        loopingOn = YES;
    }
    else {
        [self.loopButton setImage:[UIImage imageNamed:@"loop_default1.png"] forState:UIControlStateNormal];
        loopingOn = NO;
    }
    //printf("loopingOn:%d\n", (int)loopingOn);
    //[self.clientConnection.connection.processOSC packOSCMsgWithIntValue:"/prop/loop\0\0":12:(int)loopingOn];
    [self.clientConnection sendMessage:@"/prop/loop":[NSNumber numberWithBool:loopingOn]];
}

#pragma mark-
#pragma mark SoundboardViewControllerDelegate Method Implementations

- (void)soundboardViewDidFinish:(SoundboardViewController *)requestor {
    self.sbViewCntrl = nil;
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self dismissModalViewControllerAnimated: YES];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void) playTrackAtIndex:(NSIndexPath *)indexpath {
    [self.clientConnection sendMessage:@"/prop/trackplay":indexpath];
}

- (void) stopTrackAtIndex:(NSIndexPath *)indexpath {
    [self.clientConnection sendMessage:@"/prop/trackstop":nil];
}

#pragma mark-
#pragma mark ConnectionLogicDelegate Method Implementations
    
/* Error Alerts */
    // Room closed from outside
- (void)connectionTerminated:(id)sender reason:(NSString*)reason {
    
    if (self.bv != nil) [self dismissBrowser];
    if (self.sbViewCntrl != nil) [self.sbViewCntrl done];
        
    // Explain what happened
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Connection Terminated" message:reason delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
    if (self.controlsView) {
        [self.view sendSubviewToBack:self.controlsView];
        [self.view bringSubviewToFront:self.introLabel];
        
        CATransition *animation = [CATransition animation];
        [animation setDuration:1.0];
        [animation setType:kCATransitionFade];    
        [self.view.layer addAnimation:animation forKey:nil];
    }
    
    [self.playButton setImage:[UIImage imageNamed:@"play_default.png"] 
                     forState:UIControlStateNormal];
    
    [self.pauseButton setImage:[UIImage imageNamed:@"pause_default.png"] 
                     forState:UIControlStateNormal];
    
    [self.led setImage:[UIImage imageNamed:@"plug_default.png"] 
              forState:UIControlStateNormal];
    
    [self.led setImage:[UIImage imageNamed:@"plug_highlighted.png"] 
              forState:UIControlStateHighlighted];
   
    self.led.highlighted = NO;
    self.led.userInteractionEnabled = YES;
    self.status.text = @"Not Connected.";
    self.clientConnection = nil;
}

- (void)isConnected:(BOOL)state
{
    if (self.bv != nil) {
        [self dismissBrowser];
    }
    if (state) [self.toolbar setItems:connectedToolbar animated:YES];
    else [self.toolbar setItems:disconnectedToolbar animated:YES];
}

- (void)displayHeartbeat:(UInt8)val
{
    //NSLog(@"%d",val);
    //self.led.highlighted = val == 0 ? NO : YES;
    if (val > 0) {
        [self.led setImage:[UIImage imageNamed:@"heart_highlight.png"] 
                  forState:UIControlStateNormal];
    }
    else [self.led setImage:[UIImage imageNamed:@"heart_default.png"] 
                   forState:UIControlStateNormal];
}

- (void)processMessage:(id)message {    
    
    if ([message isKindOfClass:[NSString class]]) {
        if ([message isEqualToString:@"playbutt"]) {
            playingOrPaused = YES;
            [self.playButton setImage:[UIImage imageNamed:@"play_default2.png"] 
                             forState:UIControlStateNormal];
            [self.pauseButton setImage:[UIImage imageNamed:@"pause_default.png"] 
                             forState:UIControlStateNormal];
        }
        else if ([message isEqualToString:@"pausebutt"]) {
            playingOrPaused = YES;
            [self.pauseButton setImage:[UIImage imageNamed:@"pause_default2.png"] 
                             forState:UIControlStateNormal];
            [self.playButton setImage:[UIImage imageNamed:@"play_default.png"] 
                             forState:UIControlStateNormal];
        }
        else if ([message isEqualToString:@"stopbutt"]) {
            playingOrPaused = NO;
            [self.playButton setImage:[UIImage imageNamed:@"play_default.png"] 
                             forState:UIControlStateNormal];
            [self.pauseButton setImage:[UIImage imageNamed:@"pause_default.png"] 
                             forState:UIControlStateNormal];
            if (self.sbViewCntrl != nil) {
                [self.sbViewCntrl.soundboardTable cellForRowAtIndexPath:self.sbViewCntrl.selectedIndexPath].accessoryType = UITableViewCellAccessoryNone;
                self.sbViewCntrl.selectedIndexPath = nil;
            }
        }
        else self.cueItemLabel.text = message;
    }
    if ([message isKindOfClass:[NSArray class]]) {
        self.soundboardList = message;
        if (self.sbViewCntrl!=nil) {
            self.sbViewCntrl.soundboardList = self.soundboardList;
            [self.sbViewCntrl.soundboardTable reloadData];
        }
    }
    
}

- (void)didReceiveLoopStateMsg:(BOOL)state {
    
    if (state) {
        [self.loopButton setImage:[UIImage imageNamed:@"loop_default2.png"] forState:UIControlStateNormal];
        loopingOn = YES;
    }
    else {
        [self.loopButton setImage:[UIImage imageNamed:@"loop_default1.png"] forState:UIControlStateNormal];
        loopingOn = NO;
    }
}

- (void)didResolveService:(NSNetService *)service {
    //[self.clientConnection.connection.processOSC packOSCMsgWithIntValue:"/prop/loop\0\0":12:(int)loopingOn];
    [self.clientConnection sendMessage:@"/prop/loop" :[NSNumber numberWithBool:loopingOn]];
    self.led.userInteractionEnabled = NO;
}

#pragma mark-
#pragma mark ServerBrowserDelegate Method Implementations

- (void)updateServerList {
    [serverList reloadData];
    [self.activityIndicator stopAnimating];
    self.statusLabel.text = @"Connect to another Prop Phone device.";
}

#pragma mark-
#pragma mark UITableViewDelegate Method Implementations

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* currentRow = [serverList indexPathForSelectedRow];
    if ( currentRow == nil ) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Which device?" message:@"Please select which device you want to connect to from the list above" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    //printf("tableView didSelectRowAtIndexPath in BrowserViewController\n");
    
    if (![self connected]) {
        
        NSNetService* selectedServer = [serverBrowser.servers objectAtIndex:currentRow.row];
        
        ControlClient* connection = [[ControlClient alloc] initWithNetService:selectedServer];
        
        [serverBrowser stop];

        self.clientConnection = connection;
        self.status.text = [NSString stringWithFormat:@"Connected to: %@", selectedServer.name];
        
        // NSLog(@"selectedServer.name:%@",selectedServer.name);
        
        if ( self.clientConnection != nil ) {
            self.clientConnection.delegate = self;
            [self.clientConnection start];
        }

        self.statusLabel.text = @"Connecting...";
        [self.activityIndicator startAnimating];
    }
    else {
        [serverBrowser stop];
        [self dismissBrowser];
    }
}

#pragma mark-
#pragma mark UITableViewDataSource Method Implementations

// Number of rows in each section. One section by default.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [serverBrowser.servers count];
}


// Table view is requesting a cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* serverListIdentifier = @"serverListIdentifier";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:serverListIdentifier];
	if (cell == nil) {
		// cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:serverListIdentifier] autorelease];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:serverListIdentifier];
	}
    
    // Set cell's text to server's name
    NSNetService* server = [serverBrowser.servers objectAtIndex:indexPath.row];
    cell.textLabel.text = [server name];
    
    return cell;
}


@end