//
//  SCCAppDelegate.h
//  TeamAlert
//
//  Created by Jonathan Rubin on 4/26/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AddressBook/AddressBook.h>

@interface SCCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSDate *lastSyncedWithAddressBook;

- (ABAddressBookRef) addressBook;

@end
