//
//  SoundboardViewController.h
//  PropPhone
//
//  Created by Chris Lavender on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SoundboardViewController;
@protocol SoundboardViewControllerDelegate
- (void) soundboardViewDidFinish:(SoundboardViewController*)requestor;
- (void) playTrackAtIndex:(NSIndexPath*)indexpath;
- (void) stopTrackAtIndex:(NSIndexPath*)indexpath;
@end

@interface SoundboardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {

}
@property (unsafe_unretained, nonatomic) id <SoundboardViewControllerDelegate> delegate;

@property   (strong, nonatomic) IBOutlet    UITableView     *soundboardTable;
@property   (strong, nonatomic)             NSArray         *soundboardList;
@property   (strong, nonatomic)             NSIndexPath     *selectedIndexPath;
@property   (strong, nonatomic)             NSString        *currentCueTitle;

- (IBAction) done;
@end