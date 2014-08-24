//
//  SCCPaddedTableViewCell.h
//  TeamAlert
//
//  Created by Jonathan Rubin on 8/7/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCCAlertButton.h"

@interface SCCPaddedTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet SCCAlertButton *alertButton;

@end
