//
//  SCCTeamTableViewController.h
//  TeamAlert
//
//  Created by Jonathan Rubin on 6/23/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreData/CoreData.h>

@interface SCCTeamTableViewController : UITableViewController <ABPeoplePickerNavigationControllerDelegate>

- (IBAction)addContact:(id)sender;

@property (strong) NSManagedObject * team;
@property (strong) NSMutableArray  * members;

- (NSManagedObjectContext *)managedObjectContext;

- (NSManagedObject*)makeMemberFromContact:(ABRecordRef)person forTeam:(NSManagedObject *)team;

@end
