//
//  SCCMasterViewController.h
//  TeamAlert
//
//  Created by Jonathan Rubin on 4/26/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>

@class SCCDetailViewController;

@interface SCCMasterViewController : UITableViewController <UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) SCCDetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UIView *firstTeamView;

@end
