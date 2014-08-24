//
//  SCCAlertButton.m
//  TeamAlert
//
//  Created by Jonathan Rubin on 8/23/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import "SCCAlertButton.h"

@implementation SCCAlertButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage imageNamed:@"alert-button.png"] forState:UIControlStateNormal];
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
