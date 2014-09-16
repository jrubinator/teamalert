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

@property (strong) NSManagedObject     * team;
@property (strong) NSMutableOrderedSet * members;

- (NSManagedObjectContext *)managedObjectContext;
- (ABAddressBookRef)addressBook;
- (NSManagedObject*)inductContact:(ABRecordRef)person
                      contactType:(ABPropertyID)property
                       identifier:(ABMultiValueIdentifier)identifier;
- (void)displayMember:(NSManagedObject *)member;

@end
