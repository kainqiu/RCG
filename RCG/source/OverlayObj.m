//
//  OverlayObj.m
//  RCG
//
//  Created by Daniel Ho on 7/26/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "OverlayObj.h"

@implementation OverlayObj

@synthesize button;
@synthesize slider;
@synthesize label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
