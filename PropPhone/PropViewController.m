//
//  PropViewController.m
//  Prop Phone
//
//  Created by Chris Lavender on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PropViewController.h"
#import "GDMediaPlayer.h"
#import "Connection.h"

@interface PropViewController()
{
    ActionViewController    *mActionCon;
    
    BOOL    loopingOn;
    BOOL    timerSet;
    
    BOOL    timerActivated;
    BOOL    timerButtonDisplayToggle;
    
    int     countdownTime;
    int     min;
    int     sec;
}
@property (strong, nonatomic, readwrite)    GDMediaPlayer  *mediaPlayer;
@property (strong, nonatomic)        CueListViewController  *cueListCntrl;
@property (nonatomic)   BOOL    itunesOn;
@end

#pragma mark -
@implementation PropViewController

@synthesize playButton=_playButton, pauseButton= _pauseButton, stopButton= _stopButton;
@synthesize led=_led, status=_status;
@synthesize loopButton=_loopButton, timerButton=_timerButton, phoneButton=_phoneButton, ipodButton=_ipodButton;
@synthesize timerSaveButton=_timerSaveButton, timerCancelButton=_timerCancelButton;
@synthesize timerSetView=_timerSetView, timerScrollView=_timerScrollView;
@synthesize countdownLable=_countdownLable;
@synthesize mediaCollection=_mediaCollection, mediaPlayer=_mediaPlayer, cueListCntrl=_cueListCntrl;
@synthesize delegate=_delegate;
@synthesize itunesOn;

- (void)sendMediaCollectionToControlDevice {
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:self.mediaCollection.count];
    for (MPMediaItem *anItem in self.mediaCollection.items) {
        [tempArray addObject:[anItem valueForProperty:MPMediaItemPropertyTitle]];
    }
    
    [mServer sendMessage:@"/prop/cuelist" :(NSArray*)tempArray];
    // printf("PropViewController setMediaCollection sendMessage called\n");
}

- (void)setMediaCollection:(MPMediaItemCollection *)mediaCollection {
    if (mediaCollection != _mediaCollection) {
        _mediaCollection = mediaCollection;
        if (mServer.isConnected) {
            [self sendMediaCollectionToControlDevice];
        };
    }

}

- (void)setItunesOn:(BOOL)newItunesOn {
    itunesOn = newItunesOn;
    [self.mediaPlayer setSoundMode:itunesOn];

    if (itunesOn) {
        [self.ipodButton setImage:[UIImage imageNamed:@"ipod_default2.png"] forState:UIControlStateNormal];
        [self.phoneButton setImage:[UIImage imageNamed:@"phone_default1.png"] forState:UIControlStateNormal];
    }
    else {
        [self.ipodButton setImage:[UIImage imageNamed:@"ipod_default1.png"] forState:UIControlStateNormal];
        [self.phoneButton setImage:[UIImage imageNamed:@"phone_default2.png"] forState:UIControlStateNormal];
    }
}

- (void)presentAlert:(NSString*)msg {
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Oops!" 
                                                    message:msg 
                                                   delegate:nil 
                                          cancelButtonTitle:@"Ok" 
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)resetTimer {
    
    countdownTime = 0;
    min = 0;
    sec = 0;
    timerActivated = NO;
    timerButtonDisplayToggle = NO;
    
    [self.timerScrollView selectRow:0 inComponent:0 animated:YES];
    [self.timerScrollView selectRow:0 inComponent:1 animated:YES];
    
    [self.timerButton setImage:[UIImage imageNamed:@"timer_default1.png"] forState:UIControlStateNormal];
    
    self.countdownLable.text =@"";
}

- (void)formatCountdownLabel {
    int m = countdownTime / 60;
    int s = countdownTime % 60;
    // printf("countdown %d:%02d\n",m, s);
    self.countdownLable.text = [NSString stringWithFormat:@"%d : %02d",m,s];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSBundle mainBundle] loadNibNamed:@"TimerSetView" owner:self options:nil];
        
        _mediaPlayer = [[GDMediaPlayer alloc]init];
        _mediaPlayer.delegate = self;
        
        mServer = [[PropServer alloc]init];
        mServer.delegate = self;
        [mServer start];
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // retrieve the last Loop setting...
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loopButton"]) {
        loopingOn = YES;
        [self.loopButton setImage:[UIImage imageNamed:@"loop_default2.png"] forState:UIControlStateNormal];
    }
    else [self.loopButton setImage:[UIImage imageNamed:@"loop_default1.png"] forState:UIControlStateNormal];
    [self.mediaPlayer setLoopMode:loopingOn];
    
    // retrieve the last sound source setting...
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"soundSetting"])self.itunesOn = YES;
    else self.itunesOn = NO;

    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedCollection"];    
    NSArray *savedCollection = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (savedCollection.count > 0) {
        self.mediaCollection = [MPMediaItemCollection collectionWithItems:savedCollection];
        [self.mediaPlayer updatePlayerQueueWithMediaCollection: self.mediaCollection];
        self.mediaPlayer.index = 0;//insures the current track name will not be nil;
    }
     
    /*
    // retrieve the last chosen itunes track if any.
    NSNumber *anID = [[NSUserDefaults standardUserDefaults] objectForKey:@"itunesSelection"];
    if (anID != nil) {
        MPMediaQuery *query = [MPMediaQuery songsQuery]; 
        
        MPMediaPropertyPredicate *predicate = 
        [MPMediaPropertyPredicate predicateWithValue: anID forProperty: MPMediaItemPropertyPersistentID]; 
        
        [query addFilterPredicate:predicate]; 
        NSArray *mediaItems = [NSArray arrayWithArray:[query items]]; 
        //this array will consist of song with given persistentId. add it to collection and play it 
        if ([mediaItems count] > 0) self.mediaCollection = [MPMediaItemCollection collectionWithItems:mediaItems];
        [self.mediaPlayer updatePlayerQueueWithMediaCollection: self.mediaCollection];
    }
    */
    
    // if for some reason the itunesOn == YES but there was a problem retrieving an itunes reference.
    else {
        self.itunesOn = NO;
    }
    
    mTransportState = @"stop";
    self.status.text = [NSString stringWithFormat:@" "];
    self.countdownLable.text = [NSString stringWithFormat:@" "];
    self.led.hidden = YES;
    countdownTime = 0;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.playButton         =nil;
    self.pauseButton        =nil;
    self.stopButton         =nil;
    self.status             =nil;
    self.led                =nil;
    self.loopButton         =nil;
    self.timerButton        =nil;
    self.phoneButton        =nil;
    self.ipodButton         =nil;
    self.timerSaveButton    =nil;
    self.timerCancelButton  =nil;
    self.timerSetView       =nil;
    self.timerScrollView    =nil;
    self.countdownLable     =nil;
    self.mediaCollection    =nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (IBAction)loopPlaybackToggle {
        
    if (!loopingOn) {
        [self.loopButton setImage:[UIImage imageNamed:@"loop_default2.png"] forState:UIControlStateNormal];
        loopingOn = YES;
    }
    else {
        [self.loopButton setImage:[UIImage imageNamed:@"loop_default1.png"] forState:UIControlStateNormal];
        loopingOn = NO;
    }
    [self.mediaPlayer setLoopMode:loopingOn];
}

- (IBAction)mediaTransport:(id)sender {
    NSString *state = @"stop";
    
    if ([sender isKindOfClass:[UIButton class]]) {
        state = [[sender titleLabel]text];
    }
    else if ([sender isKindOfClass:[NSString class]]) {
        // NSLog(@"NSString:%@", sender);

        if ([sender isEqualToString:@"prev"]) {
            if (self.mediaPlayer.index > 0) {
                --self.mediaPlayer.index;
            }
            else if (self.mediaPlayer.index <= 0) {
                self.mediaPlayer.index = 0;
            }
            //return;
        }
        else if ([sender isEqualToString:@"next"]) {
            
            int colSize = [self.mediaPlayer.userMediaCollection count] - 1;
            
            if (self.mediaPlayer.index < colSize) {
                ++self.mediaPlayer.index;
            }
            else if (self.mediaPlayer.index >= colSize) {
                self.mediaPlayer.index = 0;
            }
            //return;
        }
        else state = sender;
}
    
    if ([state isEqualToString:@"stop"] && timerActivated) timerActivated = NO;
    
    if (mActionCon != nil) mActionCon.transportState = state;
     
    mTransportState = state;
    [self.mediaPlayer playerTransport:mTransportState];
}

- (IBAction)propViewPlayButton:(UIButton *)sender { 
    // printf("countdown %d\n", countdownTime);
    // of the count is 0 just play
    if (countdownTime == 0) {
        [self.timerScrollView reloadAllComponents];
        [self mediaTransport:sender];
        [self resetTimer];
    }
    // of timer is deactivated reset everything
    else if (!timerActivated) {
        countdownTime = 0;
        [self resetTimer];
        return;
    }
    // otherwise display the time and set the repeat
    else {
        [self formatCountdownLabel];
        countdownTime = countdownTime - 1.;
        [self performSelector:@selector(propViewPlayButton:) withObject:sender afterDelay:1.0];
    }
    if (!timerButtonDisplayToggle) {
        [self.timerButton setImage:[UIImage imageNamed:@"timer_default1.png"] 
                          forState: UIControlStateNormal];
        timerButtonDisplayToggle = YES;
    }
    else {
        [self.timerButton setImage:[UIImage imageNamed:@"timer_default2.png"] 
                          forState: UIControlStateNormal];
        timerButtonDisplayToggle = NO;
    }
}

- (IBAction)selectDefaultSound {
    
    if (self.itunesOn) {
        self.itunesOn = NO;
    }
    else {
        //[self presentAlert:@"To disable the default ringtone goto the iPod icon & select a track from your iTunes library."];
    }
}

- (IBAction)showCueList:(UIButton*)sender {

    if (self.mediaPlayer.musicPlayer.playbackState == MPMusicPlaybackStatePlaying || 
        self.mediaPlayer.musicPlayer.playbackState == MPMusicPlaybackStatePaused) 
    {
        //[self.mediaPlayer.musicPlayer stop];
        [self mediaTransport:@"stop"];
    }
    
    if (!self.itunesOn) {
        self.itunesOn = YES;
    }
    
    CueListViewController*cueListController = 
    [[CueListViewController alloc]initWithNibName:@"CueListViewController" bundle:nil];
    
    cueListController.delegate = self;
    self.cueListCntrl = cueListController;
    
    [self presentModalViewController:cueListController animated:YES];
}

- (IBAction)done
{    
    if (self.mediaPlayer.musicPlayer.playbackState == MPMusicPlaybackStatePlaying || 
        self.mediaPlayer.musicPlayer.playbackState == MPMusicPlaybackStatePaused) 
    {
        //[self.mediaPlayer.musicPlayer stop];
        [self mediaTransport:@"stop"];
    }
    self.mediaPlayer=nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:loopingOn forKey:@"loopButton"];
    [defaults setBool:self.itunesOn forKey:@"soundSetting"];
    [defaults setBool:timerSet forKey:@"timerSetting"];
    
    NSArray *currentCollection = [NSArray arrayWithArray: self.mediaCollection.items];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:currentCollection];
    [defaults setObject:data forKey:@"savedCollection"];
    
    /*
    MPMediaItem *mediaItem = [self.mediaCollection.items objectAtIndex:0]; 
    NSNumber *anId = [mediaItem valueForProperty:MPMediaItemPropertyPersistentID]; 
    [defaults setObject:anId forKey:@"itunesSelection"];
    */
    
    [defaults synchronize];

    if (mServer.isConnected) [mServer.mHeartbeatTimer invalidate];
    [mServer stop];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self.delegate killProp:self];
}

- (IBAction)showActionView;
{    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide]; 
    
    mActionCon = [[ActionViewController alloc]initWithNibName:nil bundle:nil];
    mActionCon.delegate = self;
    
    mActionCon.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:mActionCon animated:YES];
    
    mActionCon.transportState = mTransportState;
}

- (IBAction)showTimerSetView 
{
    [self resetTimer];

    self.timerSetView.center = CGPointMake(160, -200);//-175
    self.timerScrollView.showsSelectionIndicator = YES;
    
    [self.view addSubview:self.timerSetView];
    
    [UIView animateWithDuration:.5 
                     animations:^{
                         self.timerSetView.center = CGPointMake(160, 200);
                     } 
                     completion:NULL];
}

- (IBAction)setCountdownState:(UIBarButtonItem *)sender {    
    if (sender.tag == 1 && countdownTime > 0) {
        timerActivated = YES;
        [self formatCountdownLabel];
        [self.timerButton setImage:[UIImage imageNamed:@"timer_default2.png"] 
                          forState:UIControlStateNormal];
    }
    else {
        [self resetTimer];
    }
    [self dismissTimerSetView];
}

- (IBAction)dismissTimerSetView {
        
    [UIView animateWithDuration:.5 
                     animations:^{
                         self.timerSetView.center = CGPointMake(160, -200);
                     } 
                     completion:^(BOOL finished){
                         [timerSetView removeFromSuperview];
                     }];
}

#pragma mark - CueListViewController Delegate Method Impementations

- (void) playTrackAtIndex:(NSIndexPath *)indexpath
{
    self.mediaPlayer.index = indexpath.row;
    [self mediaTransport:@"play"];
}

- (void)stopTrackAtIndex:(NSIndexPath *)indexpath
{
    [self mediaTransport:@"stop"];
}

- (void) updatePlayerQueueWithMediaCollection:(MPMediaItemCollection *)mediaItemCollection
{
    self.mediaCollection = mediaItemCollection;
    [self.mediaPlayer updatePlayerQueueWithMediaCollection: self.mediaCollection];
}

- (void)cueListViewDidFinish:(CueListViewController *)requestor
{
    self.cueListCntrl=nil;
    
    if (self.mediaPlayer.musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        [self mediaTransport:@"stop"];
    }
    if (self.mediaCollection == nil && self.itunesOn) {
        self.itunesOn = NO;
        [self presentAlert:@"Your Cue List is empty."];
    }
    if (self.mediaCollection) {
        [mServer sendMessage:@"/prop/nowplay":self.mediaPlayer.currentTrack];
    }
    // needed to toggle the status bar on/off to deal with spacing wonkiness.
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self dismissModalViewControllerAnimated: YES];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

#pragma mark - ActionViewController Delegate Method Impementations
- (void)userRespondedFromActionView:(ActionViewController *)controller withAction :(NSString *)action
{
    [self.mediaPlayer playerTransport:action];
    mTransportState = action;
}

- (void)actionViewControllerDidFinish:(ActionViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
    mActionCon = nil;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide]; 
}

#pragma mark - ConnectionLogic Delegate Method Impementations

- (void) processMessage:(id)message{
    if ([message isKindOfClass:[NSString class]]) {
         [self mediaTransport:message];
    }
    else if ([message isKindOfClass:[NSIndexPath class]]) {
        self.mediaPlayer.index = ((NSIndexPath*)message).row;
    }
    else if ([message isKindOfClass:[NSNumber class]]) {
        self.itunesOn = [message boolValue];
    }
}

- (void)connectionTerminated:(id)sender reason:(NSString *)reason
{
    [mServer.mHeartbeatTimer invalidate];
    
    if (self.mediaPlayer.musicPlayer.playbackState == MPMusicPlaybackStatePlaying || 
            self.mediaPlayer.musicPlayer.playbackState == MPMusicPlaybackStatePaused) 
    {
        // [self.mediaPlayer.musicPlayer stop];
        [self mediaTransport:@"stop"];
    }
    
    // Explain what happened
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Connection Terminated" message:reason delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
    self.status.text = @" ";
    self.led.hidden = YES;
}

- (void)isConnected:(BOOL)state {
    //printf("isConnected state:%s\n", state == NO ? "NO\n" : "YES\n");
    if (state) {
        self.led.hidden = NO;
        self.status.text = @"CONNECTED!";
        // [mServer.currentConnection.processOSC packOSCMsgWithString:"/prop/nowplay\0\0" :16 :self.mediaPlayer.currentTrack];
        
        if (self.mediaCollection) [self sendMediaCollectionToControlDevice];
        [mServer sendMessage:@"/prop/nowplay" :self.mediaPlayer.currentTrack];
        [mServer sendMessage:@"/prop/loopbutt" :[NSNumber numberWithBool:loopingOn]];
    }
    else {
        self.status.text = @" ";
        
        if (self.mediaPlayer.musicPlayer.playbackState == MPMusicPlaybackStatePlaying || 
            self.mediaPlayer.musicPlayer.playbackState == MPMusicPlaybackStatePaused) 
        {
            // [self.mediaPlayer.musicPlayer stop];
            [self mediaTransport:@"stop"];
        }
    }
}
- (void)displayHeartbeat:(UInt8)val {
    self.led.highlighted = val == 0 ? NO : YES;
}

- (void)didReceiveLoopStateMsg:(BOOL)state {
    // loopPlaybackToggle actually toggles the BOOL
    // so it needs to be set to the opposite state here
    // before calling the toggle method
    if (state) {
        loopingOn = NO;
    }
    else loopingOn = YES;
    [self loopPlaybackToggle];
}

#pragma mark - UIPickerViewDataSource Method Impementations
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger numRows = 0;
    
    if (component == 0) {
        numRows = 10;
    }
    else if (component == 1) {
        numRows = 60;
    }
    return numRows;
}

#pragma mark - UIPickerViewDelegate Method Impementations
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [NSString stringWithFormat:@"%d",row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //get the values
	NSInteger newMinutes = [pickerView selectedRowInComponent:0];
	NSInteger newSeconds = [pickerView selectedRowInComponent:1];

    countdownTime = (newMinutes * 60) + newSeconds;
    
    //NSLog(@"minutes:%d seconds:%d countdown time: %d",newMinutes,newSeconds,countdownTime);
}

#pragma mark - GMMediaPlayer Delegate Method Impementations
- (void)mediaPlayerIsPlaying:(BOOL)state {
    if (state) {
        [self.playButton setImage:[UIImage imageNamed:@"play_default2.png"] 
                         forState:UIControlStateNormal];
        if (mServer.isConnected) {
            // [mServer.currentConnection.processOSC packOSCMsg:"/prop/playbutt\0\0":16];
            [mServer sendMessage:@"/prop/playbutt" :nil];
            /*
            NSString *nowItem = [self.mediaPlayer.musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
            [mServer.currentConnection.processOSC packOSCMsgWithString:"/prop/nowplay\0\0" :16 :nowItem];
             */
        }
    }
    else if (!state) {
        if (self.mediaPlayer.musicPlayer.playbackState == MPMusicPlaybackStateStopped) {

            [self.playButton setImage:[UIImage imageNamed:@"play_default.png"] 
                          forState:UIControlStateNormal];
        
            if (self.cueListCntrl != nil) {
            //[self.cueListCntrl.cueListTable deselectRowAtIndexPath:self.cueListCntrl.selectedIndexPath animated:NO];
                [self.cueListCntrl.cueListTable cellForRowAtIndexPath:self.cueListCntrl.selectedIndexPath].accessoryType = UITableViewCellAccessoryNone;
            }
            if (mServer.isConnected) {
                // [mServer.currentConnection.processOSC packOSCMsg:"/prop/stopbutt\0\0":16];
                [mServer sendMessage:@"/prop/stopbutt" :nil];
            }
            if (![mTransportState isEqualToString:@"stop"]) {
                mTransportState = @"stop";
            }
        }
        else if (self.mediaPlayer.musicPlayer.playbackState == MPMusicPlaybackStatePaused) {
            if (mServer.isConnected) {
                //printf("MPMusicPlaybackStatePaused\n");
                [mServer sendMessage:@"/prop/pausebutt":nil];
            }
        }
    }

    // if active then reset the timer elements
    if (timerActivated) {
        [self resetTimer];
        mTransportState = @"stop";
    }
}

- (void)currentTrackChanged:(GDMediaPlayer *)requestor {
    //NSLog(@"self.mediaPlayer.currentTrack:%@",requestor.currentTrack);
    if (requestor.currentTrack != nil) {
        // [mServer.currentConnection.processOSC packOSCMsgWithString:"/prop/nowplay\0\0" :16 :requestor.currentTrack];
        [mServer sendMessage:@"/prop/nowplay":requestor.currentTrack];
    }
}

@end
