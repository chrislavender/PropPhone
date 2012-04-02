//
//  DirectionsViewController.m
//  Prop Phone
//
//  Created by Chris Lavender on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DirectionsViewController.h"


@implementation DirectionsViewController
@synthesize activityWheel = _activityWheel;
- (IBAction)done
{
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    [self.activityWheel startAnimating];
}

- (void)viewDidAppear:(BOOL)animated {
    CGRect webFrame = CGRectMake(15, 10, 290, 406);  
    _webView = [[UIWebView alloc] initWithFrame:webFrame]; 
    _webView.delegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"info" ofType:@"html"] 
                                                                  isDirectory:NO]]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.view addSubview:_webView];
    [self.activityWheel stopAnimating];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType; 
{
    NSURL *requestURL =[ request URL ]; 
    if ( ( [ [ requestURL scheme ] isEqualToString: @"http" ] || [ [ requestURL scheme ] isEqualToString: @"https" ] || [ [ requestURL scheme ] isEqualToString: @"mailto" ]) 
        && ( navigationType == UIWebViewNavigationTypeLinkClicked ) ) { 
        return ![ [ UIApplication sharedApplication ] openURL: requestURL ]; 
    } 
    return YES; 
}

@end
