//
//  CueListViewController.h
//  PropPhone
//
//  Created by Chris Lavender on 9/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class CueListViewController;
@protocol CueListViewControllerDelegate
- (void) cueListViewDidFinish:(CueListViewController*)requestor;
- (void) updatePlayerQueueWithMediaCollection:(MPMediaItemCollection*)mediaItemCollection;
- (void) playTrackAtIndex:(NSIndexPath*)indexpath;
- (void) stopTrackAtIndex:(NSIndexPath*)indexpath;
@end

@interface CueListViewController : UIViewController <MPMediaPickerControllerDelegate,UITableViewDataSource, UITableViewDelegate>{
    
    NSArray *standardTopToolbar;
    NSArray *standardBottomToolbar;
    NSArray *editTopToolbar;
    NSArray *editBottomToolbar;

}
@property (unsafe_unretained, nonatomic) id <CueListViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet  UITableView     *cueListTable;
@property (strong, nonatomic) IBOutlet  UIToolbar       *topToolbar;
@property (strong, nonatomic) IBOutlet  UIToolbar       *bottomToolbar;
@property (strong, nonatomic) IBOutlet  UILabel         *titleLable;
@property (strong, nonatomic)           NSIndexPath     *selectedIndexPath;

- (IBAction) done;
- (IBAction) editCueList;
- (IBAction) clearAll;
- (IBAction) showMediaPicker;
@end