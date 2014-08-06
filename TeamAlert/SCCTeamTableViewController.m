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

- (void) displayMember:(NSManagedObject *)member {
    if ( ![self members] ) {
        self.members = [NSMutableOrderedSet orderedSetWithArray:[[self.team valueForKey:@"contacts"] allObjects]];
    }

    [[self members] addObject:member];
    [[self tableView] reloadData];
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

    // Auto-pick?

    [peoplePicker setDisplayedProperties:
        [NSArray arrayWithObjects:
            [NSNumber numberWithInt:kABPersonEmailProperty],
            [NSNumber numberWithInt:kABPersonPhoneProperty],
            nil
         ]
     ];

    return YES;
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    if ( property != kABPersonPhoneProperty && property != kABPersonEmailProperty ) {
        // TODO: error
    }

    // TODO: allow both at once? See
    // http://stackoverflow.com/questions/1320931/how-to-correctly-use-abpersonviewcontroller-with-abpeoplepickernavigationcontrol

    [self inductContact:person contactType:property identifier:identifier];
    [self dismissViewControllerAnimated:YES completion:nil];

    return NO;
}

- (NSManagedObject*)inductContact:(ABRecordRef)person
        contactType:(ABPropertyID)property
        identifier:(ABMultiValueIdentifier)identifier
{
    NSManagedObject * team      = [self team];
    NSManagedObject * newMember = [self makeMemberFromContact:person forTeam:team withContactMethod:property withIdentifier:identifier];

    // Subclasses responsible for displaying the new member
    return newMember;
}

- (NSManagedObject*)makeMemberFromContact:(ABRecordRef)person
                                  forTeam:(NSManagedObject *)team
                        withContactMethod:(ABPropertyID)property
                           withIdentifier:(ABMultiValueIdentifier)identifier
{
    NSManagedObject * teamAlertContact = [self _findTeamAlertContactForABContact:person];
    if ( !teamAlertContact ) {
        teamAlertContact = [self _createTeamAlertContactFromABContact:person];
    }

    ABMultiValueRef phonesOrEmails = ABRecordCopyValue(person, property);

    NSString * contactInfo = nil;
    NSString * contactType = nil;
    if ( property == kABPersonEmailProperty ) {
        contactType = @"email";
    }
    else if ( property == kABPersonPhoneProperty ) {
        contactType = @"phoneNumber";
    }
    // TODO: Or Error

    if (ABMultiValueGetCount(phonesOrEmails) > 0) {
        contactInfo = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phonesOrEmails, identifier);
    }
    // TODO: Or Error

    CFRelease(phonesOrEmails);

    NSManagedObjectContext *context = [self managedObjectContext];

    NSManagedObject *newMembership = [NSEntityDescription insertNewObjectForEntityForName:@"Membership" inManagedObjectContext:context];

    [newMembership setValue:contactInfo      forKey:@"contactInfo"];
    [newMembership setValue:contactType      forKey:@"contactType"];
    [newMembership setValue:teamAlertContact forKey:@"contact"];
    [newMembership setValue:team             forKey:@"team"];

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
