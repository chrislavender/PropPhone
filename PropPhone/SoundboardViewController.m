//
//  SoundboardViewController.m
//  PropPhone
//
//  Created by Chris Lavender on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundboardViewController.h"
#import "ControlViewController.h"

@implementation SoundboardViewController

static NSString* kCellIdentifier = @"itunesItemCell";

@synthesize delegate            =_delegate;
@synthesize soundboardTable     =_soundboardTable;
@synthesize soundboardList      =_soundboardList;
@synthesize selectedIndexPath   =_selectedIndexPath;
@synthesize currentCueTitle     =_currentCueTitle; //only for when the table loads the 1st time.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    self.soundboardTable=nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) done
{
    [self.delegate soundboardViewDidFinish:self];
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
        // self.selectedIndexPath is set to nil in ControlViewController when stopbutt is recieved
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

    int rowCount = self.soundboardList.count;
    
    return rowCount;
    return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{        
    NSInteger row = [indexPath row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kCellIdentifier];
	
	if (cell == nil)
    {
        //	cell = [[[UITableViewCell alloc] initWithFrame: CGRectZero reuseIdentifier: kCellIdentifier] autorelease];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];

	}

	NSString *anItem = [self.soundboardList objectAtIndex: row];
    
	if (anItem) {
		cell.textLabel.text = anItem;
    }
    
    if ([indexPath isEqual:self.selectedIndexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else if ([anItem isEqualToString:self.currentCueTitle]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.currentCueTitle = nil;
        self.selectedIndexPath = indexPath;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


@end
