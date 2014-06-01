//
//  SCCNewTeamTableViewController.h
//  TeamAlert
//
//  Created by Jonathan Rubin on 6/1/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreData/CoreData.h>

@interface SCCNewTeamTableViewController : UITableViewController <ABPeoplePickerNavigationControllerDelegate>
- (IBAction)addContact:(id)sender;

@end
