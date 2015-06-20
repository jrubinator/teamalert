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
#import "SCCErrorDisplayDelegate.h"

@interface SCCTeamTableViewController : UITableViewController <ABPeoplePickerNavigationControllerDelegate, SCCErrorDisplayDelegate>

- (IBAction)addContact:(id)sender;

@property (strong) NSManagedObject     * team;
@property (strong) NSMutableOrderedSet * members;

- (NSManagedObjectContext *)managedObjectContext;
- (ABAddressBookRef)addressBook;
- (NSManagedObject*)inductContact:(ABRecordRef)person
                      contactType:(ABPropertyID)property
                       identifier:(ABMultiValueIdentifier)identifier;
- (NSString *)getFullNameForPerson:(ABRecordRef)person;
- (NSString *)getFullNameForContact:(NSManagedObject *)contact;
- (void)displayMember:(NSManagedObject *)member;
- (void) ensureAddressBookAccessOnSuccess:(void (^)(void))successCallback
                                onFailure:(void (^)(void))failureCallback;

@end
