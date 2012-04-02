//
//  ActionViewController.m
//  propPractice
//
//  Created by Chris Lavender on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActionViewController.h"
#import "PropPhoneAppDelegate.h" // for the version number property

@interface ActionViewController()
{
    UIView      *currentView;
    UIScreen    *theScreen;
    BOOL        ver5;
    CGFloat     brightness;
}
@end

@implementation ActionViewController

@synthesize delegate        =_delegate;

@synthesize transportState  = _transportState;

@synthesize upperLock       =_upperLock;
@synthesize lowerLock       =_lowerLock;
@synthesize unlockImage     =_unlockImage;
@synthesize instructionView =_instructionView;

- (void)turnScreenOn {
    if (ver5) theScreen.brightness = brightness;
}

- (void)midwayScreenOn {
    if (ver5) theScreen.brightness = brightness*.5;
}


- (void)updateScreenImage {
    if ([self.transportState isEqualToString:@"play"] && currentView != incomingCallView) {
        [self.view addSubview:incomingCallView];
        [currentView removeFromSuperview];
        currentView = incomingCallView;
        [self performSelector:@selector(turnScreenOn) withObject:nil afterDelay:0.3];
    }
    else if ([self.transportState isEqualToString:@"pause"] && currentView != endCallview){
        [self.view addSubview:endCallview];
        [currentView removeFromSuperview];
        currentView = endCallview;
        [self performSelector:@selector(turnScreenOn) withObject:nil afterDelay:0.3];
    }
    else if ([self.transportState isEqualToString:@"stop"] && currentView != standbyView){
        theScreen.brightness = 0.0;
        [self.view addSubview:standbyView];
        [currentView removeFromSuperview];
        currentView = standbyView;
    }
}

- (void)setTransportState:(NSString *)transportState {
    _transportState = transportState;
    [self updateScreenImage];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
            //customizations...
        
        float ver = ((PropPhoneAppDelegate*)[UIApplication sharedApplication].delegate).versionNum;
        if (ver >= 5.0) ver5 = YES;
        
        brightness = ((PropPhoneAppDelegate*)[UIApplication sharedApplication].delegate).brightLevel;

        
        //This class is just a controller to manage the different sub-views
        [[NSBundle mainBundle] loadNibNamed:@"EndCallView"      owner:self options:nil];
        [[NSBundle mainBundle] loadNibNamed:@"IncomingCallView" owner:self options:nil];
        [[NSBundle mainBundle] loadNibNamed:@"StandbyView"      owner:self options:nil];
        }
    
    

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (ver5) {
        theScreen = [UIScreen mainScreen];
        // theScreen.wantsSoftwareDimming = YES;
    }
    
    [self.view addSubview:standbyView];
    currentView = standbyView;
    self.instructionView.delegate = self;
    
}

- (void) dimScreen {

    if (theScreen.brightness <= 0.0) {
        theScreen.brightness = 0.0;
    }
    else if (theScreen.brightness > 0.0) theScreen.brightness -= 0.01;
    
    if (theScreen.brightness > 0.0 && currentView == standbyView) {
        if (self.view.window != nil) {
            [self performSelector:@selector(dimScreen) withObject:nil afterDelay:0.05];
        }
    }
    else {
        [self.instructionView removeFromSuperview];
    }
}

- (void) displayInstruction {
    if (self.instructionView.alpha <= 0.0) {
        self.instructionView.alpha = 0.0;
    }
    else if (self.instructionView.alpha > 0.0) self.instructionView.alpha -= 0.01;
    
    if (self.instructionView.alpha > 0.0 && currentView == standbyView) {
        [self performSelector:@selector(displayInstruction) withObject:nil afterDelay:0.05];
    }
    else {
        [self.instructionView removeFromSuperview];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    
    if (currentView == standbyView) {
        
        [self.view addSubview:self.instructionView];
        self.instructionView.center = self.view.center;
        [self.view bringSubviewToFront:self.instructionView];
        
        if (ver5) [self dimScreen];
        else [self displayInstruction];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.lowerLock          =nil;
    self.upperLock          =nil;
    self.unlockImage        =nil;
    self.instructionView   =nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)done;
{
    if (ver5) {
        // theScreen.wantsSoftwareDimming = NO;
        theScreen.brightness = brightness;
    }
    
    [self.delegate actionViewControllerDidFinish:self];
}

#pragma mark - IBActions

- (IBAction)unlock:(UIButton *)sender {
    if (sender == self.upperLock) {
        self.upperLock.selected = YES;
        if (self.lowerLock.selected == YES) {
            [self turnScreenOn];
            self.unlockImage.hidden = NO;
            [self performSelector:@selector(done) withObject:nil afterDelay:0.5];
        }
        else [self midwayScreenOn];
    }
    else if (sender == self.lowerLock) {
        self.lowerLock.selected = YES;
        
        if (self.upperLock.selected == YES) {
            [self turnScreenOn];
            self.unlockImage.hidden = NO;
            [self performSelector:@selector(done) withObject:nil afterDelay:0.5];
        }
        else [self midwayScreenOn];
    }
}

- (IBAction)answerCall 
{
    [self.delegate userRespondedFromActionView:self withAction:@"pause"];
    self.transportState = @"pause";
    //printf("call answered\n");
}

- (IBAction)endCall
{
    [self.delegate userRespondedFromActionView:self withAction:@"stop"];
    self.transportState = @"stop";
    //printf("call declined\n");
}

#pragma mark-
#pragma mark CustomControl Delegate Method Implementations

- (void)customControlDidFinish:(CustomControl *)requestor {
    [self.view sendSubviewToBack:self.instructionView];
}
 
@end
