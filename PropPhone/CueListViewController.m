//
//  CueListViewController.m
//  PropPhone
//
//  Created by Chris Lavender on 9/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CueListViewController.h"
#import "PropViewController.h"

@interface CueListViewController()
@end

@implementation CueListViewController

static NSString* kCellIdentifier = @"itunesItemCell";

@synthesize delegate=_delegate;
@synthesize cueListTable=_cueListTable;
@synthesize topToolbar=_topToolbar, bottomToolbar=_bottomToolbar,titleLable=_titleLable;
@synthesize selectedIndexPath=_selectedIndexPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *edit = [[UIBarButtonItem alloc]initWithTitle:@"Edit" 
                                                                style:UIBarButtonItemStyleBordered 
                                                               target:self 
                                                               action:@selector(editCueList)];

        UIBarButtonItem *exit = [[UIBarButtonItem alloc]initWithTitle:@"Exit" 
                                                                style:UIBarButtonItemStyleDone 
                                                               target:self 
                                                               action:@selector(done)];
        UIBarButtonItem *clear = [[UIBarButtonItem alloc]initWithTitle:@"Clear All" 
                                                                 style:UIBarButtonItemStyleDone 
                                                                target:self 
                                                                action:@selector(clearAll)];
        UIBarButtonItem *add = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                            target:self 
                                                                            action:@selector(showMediaPicker)];
        UIBarButtonItem *done = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                             target:self 
                                                                             action:@selector(editCueList)];
        UIBarButtonItem *flex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                             target:self 
                                                                             action:nil];
        UIBarButtonItem *fix = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace 
                                                                            target:self 
                                                                            action:nil];
        fix.width = 62;
        
        standardTopToolbar      = [[NSArray alloc]initWithObjects:flex, edit, nil];
        standardBottomToolbar   = [[NSArray alloc]initWithObjects:exit, nil];
        editTopToolbar          = [[NSArray alloc]initWithObjects:clear, fix, add, flex ,done, nil];
        editBottomToolbar       = [[NSArray alloc]initWithObjects: nil];
        
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
    [self.topToolbar setItems:standardTopToolbar animated:YES];
    [self.bottomToolbar setItems:standardBottomToolbar animated:YES];
}

- (void) viewDidAppear:(BOOL)animated
{

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.topToolbar     =nil;
    self.bottomToolbar  =nil;
    self.cueListTable   =nil;
    self.titleLable     =nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - IBActions Method Implementations

- (IBAction)editCueList
{
    if(self.cueListTable.editing)
	{
		[self.cueListTable setEditing:NO animated:YES];
		[self.cueListTable reloadData];
        
        [self.view bringSubviewToFront:self.titleLable];
        
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setType:kCATransitionFade];    
        [self.view.layer addAnimation:animation forKey:nil];
        
        [self.topToolbar setItems:standardTopToolbar animated:YES];
        [self.bottomToolbar setItems:standardBottomToolbar animated:YES];
	}
	else
	{
        if (((PropViewController*)self.delegate).mediaPlayer.musicPlayer.playbackState == (MPMusicPlaybackStatePlaying | MPMusicPlaybackStatePaused)) {
            [((PropViewController*)self.delegate) mediaTransport:@"stop"];
        }
		[self.cueListTable setEditing:YES animated:YES];
		[self.cueListTable reloadData];
        
        [self.view sendSubviewToBack:self.titleLable];
        
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setType:kCATransitionFade];    
        [self.view.layer addAnimation:animation forKey:nil];
        
        [self.topToolbar setItems:editTopToolbar animated:YES];
	    [self.bottomToolbar setItems:editBottomToolbar animated:YES];
	}
}

- (IBAction)clearAll {
    [self.delegate updatePlayerQueueWithMediaCollection:nil];
    [self.cueListTable reloadData];
}

- (IBAction)showMediaPicker
{
     MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];                   
     
     [picker setDelegate: self];
     [picker setAllowsPickingMultipleItems: YES];
     
     picker.prompt = NSLocalizedString (@"Select files from your iTunes Library",
     "Prompt in media item picker");
     
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated:YES];

     [self presentModalViewController: picker animated: YES];
}

- (IBAction) done
{
    [self.delegate cueListViewDidFinish:self];
}

#pragma mark -
#pragma mark MPMediaPickerControllerDelegate Method Implementations

- (void) mediaPicker:(MPMediaPickerController*)mediaPicker didPickMediaItems:(MPMediaItemCollection*)mediaItemCollection
{   
    // need to insert mutable array here to add incoming mediaItemCollection to any existing list items.
	
    // Combine the previously-existing media item collection with the new one
    if (((PropViewController*)self.delegate).mediaCollection.items.count > 0) {
        
        NSMutableArray *combinedMediaItems	= [((PropViewController*)self.delegate).mediaCollection.items mutableCopy];
        [combinedMediaItems addObjectsFromArray: mediaItemCollection.items];
        [self.delegate updatePlayerQueueWithMediaCollection:[MPMediaItemCollection collectionWithItems:(NSArray*)combinedMediaItems]];
    }
    else
        [self.delegate updatePlayerQueueWithMediaCollection:mediaItemCollection];

	[self.cueListTable reloadData];
	
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque 
                                                animated:YES];
    
    [self dismissModalViewControllerAnimated: YES];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque 
                                                animated:YES];
    [self dismissModalViewControllerAnimated: YES];
    
}

#pragma mark -
#pragma mark UITableViewDelegate Method Implementations

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // anything selected should begin playing in the media player
    // NSLog(@"did select row:%d",indexPath.row);
    
    if ([self.selectedIndexPath isEqual:indexPath] ) {
        [self.delegate stopTrackAtIndex:indexPath];
        [tableView cellForRowAtIndexPath:indexPath].accessoryType=UITableViewCellAccessoryNone;
        self.selectedIndexPath=nil;
    }
    else {
        [self.delegate playTrackAtIndex:indexPath];
        [tableView cellForRowAtIndexPath:self.selectedIndexPath].accessoryType=UITableViewCellAccessoryNone;
        [tableView cellForRowAtIndexPath:indexPath].accessoryType=UITableViewCellAccessoryCheckmark;
        self.selectedIndexPath = indexPath;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource Method Implementations

// Number of rows in each section. One section by default.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
	MPMediaItemCollection *currentQueue = ((PropViewController*)self.delegate).mediaCollection;
    
    int rowCount = [currentQueue.items count];
    
    return rowCount;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{        
    NSInteger row = [indexPath row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kCellIdentifier];
	
	if (cell == nil)
    {
		// cell = [[[UITableViewCell alloc] initWithFrame: CGRectZero reuseIdentifier: kCellIdentifier] autorelease];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
	}

	MPMediaItemCollection *currentQueue = ((PropViewController*)self.delegate).mediaCollection;
	MPMediaItem *anItem = (MPMediaItem *)[currentQueue.items objectAtIndex: row];
    
	if (anItem) 
    {
		cell.textLabel.text = [anItem valueForProperty:MPMediaItemPropertyTitle];
        cell.showsReorderControl = YES;
	}
    
    if ([indexPath isEqual:self.selectedIndexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
	[tableView deselectRowAtIndexPath: indexPath animated: NO];
    
	return cell;
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath 
{    
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:((PropViewController*)self.delegate).mediaCollection.items];
    
    id tempObject = [tempArray objectAtIndex:[sourceIndexPath indexAtPosition:1]];
    [tempArray removeObjectAtIndex:[sourceIndexPath indexAtPosition:1]];
    [tempArray insertObject:tempObject atIndex:[destinationIndexPath indexAtPosition:1]];
    
    if (tempArray.count > 0) {
        [self.delegate updatePlayerQueueWithMediaCollection:[MPMediaItemCollection collectionWithItems:tempArray]];
    }
    else [self.delegate updatePlayerQueueWithMediaCollection:nil];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source        
        NSMutableArray *tempArray = 
        [[NSMutableArray alloc] initWithArray:((PropViewController*)self.delegate).mediaCollection.items];
        
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            
            [tempArray removeObjectAtIndex:indexPath.row];
            if (tempArray.count == 0) {
                [self.delegate updatePlayerQueueWithMediaCollection:nil];
            }
            else [self.delegate updatePlayerQueueWithMediaCollection: [MPMediaItemCollection collectionWithItems: tempArray]];
            
            [tableView reloadData];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


@end
