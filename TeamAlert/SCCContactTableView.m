//
//  SCCContactTableView.m
//  TeamAlert
//
//  Created by Jonathan Rubin on 5/26/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import "SCCContactTableView.h"

@implementation SCCContactTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIView *paintView=[[UIView alloc]initWithFrame:CGRectMake(0, 50, 320, 430)];
        [paintView setBackgroundColor:[UIColor yellowColor]];
        self.tableHeaderView = paintView;
        NSLog(@"hi");
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

- (id)init
{
    NSLog(@"uh ahhh");
    return [super init];
}

@end
