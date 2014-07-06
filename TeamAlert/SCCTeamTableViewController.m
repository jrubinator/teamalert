//
//  SCCTeamTableViewController.m
//  TeamAlert
//
//  Created by Jonathan Rubin on 6/23/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//
//  This file is not (currently) intended for direct usage
//  Rather, it is expected to be inherited by other TableViewControllers
//  which will implement custom displays found throughout the app

#import "SCCTeamTableViewController.h"

@interface SCCTeamTableViewController ()


@end

@implementation SCCTeamTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Just a simple list of contacts
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self members] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Contact" forIndexPath:indexPath];

    // Configure the cell...
    NSObject *member = [self.members objectAtIndex:indexPath.row];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@ %@", [member valueForKey:@"firstName"], [member valueForKey:@"lastName"]]];
    //[cell.detailTextLabel setText:[member valueForKey:@"phoneNumber"]];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Manage Object Context

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)] ) {
        context = [delegate managedObjectContext];
    }
    return context;
}

# pragma mark - Contact Picker
- (IBAction)addContact:(id)sender {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;

    [self presentViewController:picker animated:YES completion:nil];
}

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {

    [self inductContact:person];
    [self dismissViewControllerAnimated:YES completion:nil];

    return NO;
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    //Never reached
    return NO;
}

- (void)inductContact:(ABRecordRef) person {
    NSLog(@"Picked person %@", person);
}

- (NSManagedObject*)makeMemberFromContact:(ABRecordRef)person forTeam:(NSManagedObject *)team
{
    NSManagedObject * teamAlertContact = [self _findTeamAlertContactForABContact:person];
    if ( !teamAlertContact ) {
        teamAlertContact = [self _createTeamAlertContactFromABContact:person];
    }

    NSString * phone = nil;
    NSString * email = nil;

    ABMultiValueRef phoneNumbers   = ABRecordCopyValue(person, kABPersonPhoneProperty);
    ABMultiValueRef emailAddresses = ABRecordCopyValue(person, kABPersonEmailProperty);

    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    }

    if (ABMultiValueGetCount(emailAddresses) > 0) {
        email = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(emailAddresses, 0);
    }

    CFRelease(phoneNumbers);
    CFRelease(emailAddresses);

    NSManagedObjectContext *context = [self managedObjectContext];

    NSManagedObject *newPhoneMembership = [NSEntityDescription insertNewObjectForEntityForName:@"Membership" inManagedObjectContext:context];

    [newPhoneMembership setValue:phone          forKey:@"contactInfo"];
    [newPhoneMembership setValue:@"phoneNumber"   forKey:@"contactType"];
    [newPhoneMembership setValue:teamAlertContact forKey:@"contact"];
    [newPhoneMembership setValue:team             forKey:@"team"];

    NSManagedObject *newEmailMembership = [NSEntityDescription insertNewObjectForEntityForName:@"Membership" inManagedObjectContext:context];

    [newEmailMembership setValue:email            forKey:@"contactInfo"];
    [newEmailMembership setValue:@"email"         forKey:@"contactType"];
    [newEmailMembership setValue:teamAlertContact forKey:@"contact"];
    [newEmailMembership setValue:team             forKey:@"team"];

    return teamAlertContact;
}

#pragma mark Internal Methods
- (NSManagedObject *)_findTeamAlertContactForABContact:(ABRecordRef)person
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription    *entityDescription = [NSEntityDescription entityForName:@"Contact"
                                                            inManagedObjectContext:context];

    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];

    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(recordID = %i)", ABRecordGetRecordID(person)];
    [request setPredicate:predicate];

    [request setFetchLimit:1];

    NSError * error;
    NSArray * contactArray = [context executeFetchRequest:request error:&error];
    if ( error ) {
         NSLog(@"Cannot Retrieve Contact! %@ %@", error, [error localizedDescription]);
        return nil;
    }

    if ( ![contactArray count] ) { return nil; }

    // TODO: check that the name is what's expected
    return [contactArray objectAtIndex:0];
}

- (NSManagedObject *)_createTeamAlertContactFromABContact:(ABRecordRef)person
{
    NSNumber * recordID = [NSNumber numberWithInt:ABRecordGetRecordID(person)];
    NSString * firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString * lastName  = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);

    NSManagedObjectContext * context = [self managedObjectContext];

    NSManagedObject *newContact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];

    [newContact setValue:recordID  forKey:@"recordID"];
    [newContact setValue:firstName forKey:@"firstName"];
    [newContact setValue:lastName  forKey:@"lastName"];

    return newContact;
}

@end
