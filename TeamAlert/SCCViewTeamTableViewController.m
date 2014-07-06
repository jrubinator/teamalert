//
//  SCCViewTeamTableViewController.m
//  TeamAlert
//
//  Created by Jonathan Rubin on 6/26/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import "SCCViewTeamTableViewController.h"

@interface SCCViewTeamTableViewController ()

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


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete an object form the database
        NSManagedObject *contact = [self.members objectAtIndex:indexPath.row];
        if ( [self deleteContact:contact]) {
            // And delete it from the UI
            [self.members removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
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
    NSManagedObject * team      = [self team];
    NSManagedObject * newMember = [self makeMemberFromContact:person forTeam:team];

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

- (BOOL)deleteContact:(NSManagedObject *)contact {

    NSManagedObject *team           = [self team];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Membership"
                                                                  inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];

    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"(team = %@) AND (contact = %@)", team, contact];
    [request setPredicate:predicate];

    NSError *contextError;
    NSArray *contactMemberships = [context executeFetchRequest:request error:&contextError];
    if (contactMemberships == nil)
    {
        NSLog(@"Maybe that contact wasn't associated with this team? Error: %@", contextError);
    }
    else {
        for (NSManagedObject *membership in contactMemberships) {
            [context deleteObject:membership];
        }

        if ( [[contact valueForKey:@"teams"] count] == 1 ) {
            [context deleteObject:contact];
        }

        if ( ![context save:&contextError] ) {
            NSLog(@"Cannot Delete Contact! %@ %@", contextError, [contextError localizedDescription]);
        }
        else {
            // Make sure the UI reflects the deletion
            [context refreshObject:team mergeChanges:YES];
            return YES;
        }
    }
    return NO;
}

@end
