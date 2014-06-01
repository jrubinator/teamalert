//
//  SCCNewTeamViewController.h
//  TeamAlert
//
//  Created by Jonathan Rubin on 5/29/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreData/CoreData.h>

@interface SCCNewTeamViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate>
- (IBAction)addContact:(id)sender;


@property (weak, nonatomic) IBOutlet UITableView *contactTableView;

@end
