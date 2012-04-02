//
//  MainViewController.m
//  Prop Phone
//
//  Created by Chris Lavender on 8/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "AppConfig.h"
#import "PropPhoneAppDelegate.h"

@interface MainViewController() {
    PropPhoneAppDelegate *appDel; 
}
@end

@implementation MainViewController
@synthesize comedy = _comedy, tragedy = _tragedy;
@synthesize propView, controlView;

- (void)viewDidLoad {
    [AppConfig getInstance].name = [UIDevice currentDevice].name;
    appDel = (PropPhoneAppDelegate *)[[UIApplication sharedApplication]delegate];
}


#pragma mark - Actions

- (IBAction)showDirections
{
    directions = [[DirectionsViewController alloc]init];
    directions.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:directions animated:YES];
    
}

- (void)transitionToPropMode {    
    // get the view that's currently showing
	UIView *currentView = self.view;
	// get the the underlying UIWindow, or the view containing the current view view
	UIView *theWindow = [currentView superview];

    // remove the current view and replace with newView
	[currentView removeFromSuperview];
	[theWindow addSubview:propView.view];
    
    // set up an animation for the transition between the views
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
	[[theWindow layer] addAnimation:animation forKey:nil];
    [appDel.actWheel stopAnimating];
    self.tragedy.highlighted = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (IBAction)enablePropMode 
{   
    [self.tragedy rotateCCW];

    [appDel.window bringSubviewToFront:appDel.actWheel];
    [appDel.actWheel startAnimating];
    if ([appDel.actWheel isAnimating]) {
        propView = [[PropViewController alloc]init];
        propView.delegate = self;
        
        // needed the following peformSelector afterDelay in order to display 
        // the activity wheel in the current view rather than the next view.
        [self performSelector:@selector(transitionToPropMode) withObject:nil afterDelay:0];
    }
}

- (void)transitionToControlMode {
        
    // get the view that's currently showing
	UIView *currentView = self.view;
	// get the the underlying UIWindow, or the view containing the current view view
	UIView *theWindow = [currentView superview];
    
    // remove the current view and replace with newView
	[currentView removeFromSuperview];
	[theWindow addSubview:controlView.view];
    
    // set up an animation for the transition between the views
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromLeft];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
	[[theWindow layer] addAnimation:animation forKey:nil];

    [appDel.actWheel stopAnimating];
    self.comedy.highlighted = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (IBAction)enableControlMode
{
    [self.comedy rotateCW];

    [appDel.window bringSubviewToFront:appDel.actWheel];
    [appDel.actWheel startAnimating];
    if ([appDel.actWheel isAnimating]) {
        controlView = [[ControlViewController alloc]init];
        controlView.delegate = self;
        [self performSelector:@selector(transitionToControlMode) withObject:nil afterDelay:0];
    }
}

#pragma mark - Delegate Protocols

- (void)killProp:(PropViewController *)requestor
{
	UIView *currentView = propView.view;
	UIView *theWindow = [currentView superview];
	
	[currentView removeFromSuperview];
	[theWindow addSubview:self.view];
	
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromLeft];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

	[[theWindow layer] addAnimation:animation forKey:nil];
    propView = nil;
}

- (void)killControl:(ControlViewController *)requestor
{
	UIView *currentView = controlView.view;
	UIView *theWindow = [currentView superview];
	
	[currentView removeFromSuperview];
	[theWindow addSubview:self.view];
	
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[theWindow layer] addAnimation:animation forKey:nil];
    controlView = nil;
}


@end