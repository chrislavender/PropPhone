//
//  PropPhoneAppDelegate.h
//  PropPhone
//
//  Created by Chris Lavender on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface PropPhoneAppDelegate : NSObject <UIApplicationDelegate> {
    MainViewController  *_mvc;
    UIDevice            *_device;
}

@property (strong, nonatomic) IBOutlet  UIWindow                *window;
@property (strong, nonatomic) IBOutlet  UIActivityIndicatorView *actWheel;
@property (strong, nonatomic)           UIScreen                *theScreen;
@property (nonatomic) CGFloat versionNum;
@property (nonatomic) CGFloat brightLevel;

// Main instance of the app delegate
+ (PropPhoneAppDelegate*)getInstance;

@end
