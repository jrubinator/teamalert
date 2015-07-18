//
//  SCCPaddedTableViewCell.m
//  TeamAlert
//
//  Created by Jonathan Rubin on 8/7/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import "SCCPaddedTableViewCell.h"

@implementation SCCPaddedTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// Make the table cell smaller so there is a right margin
// Doing this through insets causes the cell to stay the same width
// And the margin to appear offscreen
- (void)setFrame:(CGRect)frame {
    CGFloat xInset = 10.f;

    frame.origin.x   +=     xInset;
    frame.size.width = self.superview.frame.size.width - 2.f * xInset;

    [super setFrame:frame];
}

// Background around everything, including accessoryView
- (void)layoutSubviews
{
    [super layoutSubviews];

    // Leave about 1/10 of the image's width (ie. ~ 4px) as a right margin
    CGRect accessoryViewFrame = self.accessoryView.frame;
    float origX = accessoryViewFrame.origin.x;
    float newX  = CGRectGetWidth(self.bounds) - 1.1 * CGRectGetWidth(accessoryViewFrame);
    accessoryViewFrame.origin.x = newX;
    self.accessoryView.frame = accessoryViewFrame;

    // Add that extra space to the label length
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.size.width = textLabelFrame.size.width + (newX - origX);
    self.textLabel.frame = textLabelFrame;

    [self.contentView.superview.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.contentView.superview.layer setBorderWidth:1.0f];
}

@end
