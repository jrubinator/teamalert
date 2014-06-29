//
//  SCCViewTeamTableViewController.m
//  TeamAlert
//
//  Created by Jonathan Rubin on 6/26/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import "SCCViewTeamTableViewController.h"

@interface SCCViewTeamTableViewController ()
@property (strong) NSManagedObject * team;

@end

@implementation SCCViewTeamTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self navigationItem] setTitle:[self.team valueForKey:@"name"]];

    [self.addContactView setHidden:!self.editing];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    // Display "+ Add Contact" if editing
    [self.addContactView setHidden:!editing];

    [super setEditing:editing animated:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setDetailItem:(NSManagedObject *)team
{
    self.team    = team;
    self.members = [NSMutableArray arrayWithArray:[[team valueForKey:@"contacts"] allObjects]];
}

# pragma mark - Contact Handling

- (void)inductContact:(ABRecordRef)person
{
    NSManagedObject * newMember = [self makeMemberFromContact:person];
    NSManagedObject * team      = [self team];

    for (NSManagedObject *membership in [newMember valueForKey:@"memberships"]) {
        [membership setValue:team forKey:@"team"];
    }

    NSManagedObjectContext * context = [self managedObjectContext];
    NSError *saveError = nil;
    if (![context save:&saveError]) {
        NSLog(@"Could not save new team: %@, %@", saveError, [saveError localizedDescription]);
    }
    else {
        [[self members] addObject:newMember];
        // Make sure the new contact displays the next time the page is loaded
        [context refreshObject:team mergeChanges:YES];
    }

    [[self tableView] reloadData];
}

@end
