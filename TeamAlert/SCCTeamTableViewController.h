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

@interface SCCTeamTableViewController : UITableViewController

@property (strong) NSMutableArray * members;

- (NSManagedObjectContext *)managedObjectContext;

@end
