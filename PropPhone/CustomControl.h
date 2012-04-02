//
//  CustomControl.h
//  PropPhone
//
//  Created by Chris Lavender on 10/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomControl;
@protocol CustomControlDelegate
- (void) customControlDidFinish:(CustomControl*)requestor;
@end

@interface CustomControl : UIView
@property (unsafe_unretained, nonatomic) id<CustomControlDelegate> delegate;

@end
