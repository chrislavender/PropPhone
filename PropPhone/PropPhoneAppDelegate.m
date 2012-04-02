//
//  PropPhoneAppDelegate.m
//  PropPhone
//
//  Created by Chris Lavender on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PropPhoneAppDelegate.h"

static PropPhoneAppDelegate* _instance;

@implementation PropPhoneAppDelegate

@synthesize theScreen   =_theScreen;
@synthesize actWheel    =_actWheel;
@synthesize window      =_window;

@synthesize versionNum;
@synthesize brightLevel;


- (void)undimScreen {
    if (self.versionNum >= 5.0) {
        if (self.brightLevel > 0.2) {
            self.theScreen.brightness = self.brightLevel;
        }
        else self.theScreen.brightness = 0.5;
        // printf("undimScreen\n");
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.versionNum =[[UIDevice currentDevice].systemVersion floatValue];
    self.theScreen = [UIScreen mainScreen];
    
    if (self.versionNum >= 5.0) {
         self.brightLevel = self.theScreen.brightness;
    }

    
    [self undimScreen];
    
    [application setIdleTimerDisabled:YES];

    _mvc = [[MainViewController alloc] init];
    
    [self.window addSubview:_mvc.view];  
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // printf("applicationWillResignActive\n");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    // printf("applicationDidEnterBackground\n");

    [self undimScreen];
    
    [application setIdleTimerDisabled:NO];
    
    if (_mvc.propView != nil) {
        [_mvc.propView done];
        // printf("propView done called\n");
    }
    
    else if (_mvc.controlView != nil) {
        [_mvc.controlView done];
        // printf("controlView done called\n");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self undimScreen];

    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */     
}


+ (PropPhoneAppDelegate*)getInstance {
    return _instance;
}
@end
