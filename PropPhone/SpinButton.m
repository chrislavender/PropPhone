//
//  SpinButton.m
//  Thumbafon
//
//  Created by Chris Lavender on 12/27/10.
//  Copyright 2010 Gnarly Dog Music. All rights reserved.
//

#import "SpinButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation SpinButton

@synthesize buttonType;


-(void)rotateCW
{
    CABasicAnimation *fullRotationAnimation;
    fullRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    fullRotationAnimation .fromValue = [NSNumber numberWithFloat:0];
    fullRotationAnimation.toValue = [NSNumber numberWithFloat:(-2 * M_PI)];
    fullRotationAnimation.duration = .5;          // speed for the rotation. Smaller number is faster
    fullRotationAnimation.repeatCount = 1.;  // number of times to spin. 1 = once
    [self.imageView.layer addAnimation:fullRotationAnimation forKey:@"360CW"];
    
}  

-(void)rotateCCW
{
    CABasicAnimation *fullRotationAnimation;
    fullRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    fullRotationAnimation .fromValue = [NSNumber numberWithFloat:0];
    fullRotationAnimation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
    fullRotationAnimation.duration = .5;    
    fullRotationAnimation.repeatCount = 1.; 
    [self.imageView.layer addAnimation:fullRotationAnimation forKey:@"360CCW"];
    
}  


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.highlighted = YES;
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {		
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.highlighted = NO;
}

@end
