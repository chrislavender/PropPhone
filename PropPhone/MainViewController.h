//
//  MainViewController.h
//  Prop Phone
//
//  Created by Chris Lavender on 8/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DirectionsViewController.h"
#import "PropViewController.h"
#import "ControlViewController.h"
#import "SpinButton.h"


@interface MainViewController : UIViewController <PropViewControllerDelegate, ControlViewControllerDelegate>
{
    DirectionsViewController    *directions;
    PropViewController          *propView;
    ControlViewController       *controlView;
}

@property (strong, nonatomic) IBOutlet SpinButton *comedy;
@property (strong, nonatomic) IBOutlet SpinButton *tragedy;

@property (nonatomic, readonly) PropViewController    *propView;
@property (nonatomic, readonly) ControlViewController *controlView;

- (IBAction)showDirections;
- (IBAction)enablePropMode;
- (IBAction)enableControlMode;

@end
