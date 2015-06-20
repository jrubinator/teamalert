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
    NSManagedObject *member = [self.members objectAtIndex:indexPath.row];

    [cell.textLabel setText:[self getFullNameForContact:member]];
    //[cell.detailTextLabel setText:[member valueForKey:@"phoneNumber"]];

    return cell;
}

- (void) displayMember:(NSManagedObject *)member {
    if ( !member ) {
        return;
    }

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

#pragma mark - App Delegate Accesssors

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate respondsToSelector:@selector(managedObjectContext)] ) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (ABAddressBookRef)addressBook {
    ABAddressBookRef ab;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate respondsToSelector:@selector(addressBook)] ) {
        ab = [delegate addressBook];
    }
    return ab;
}

- (void) ensureAddressBookAccessOnSuccess:(void (^)(void))successCallback
                                onFailure:(void (^)(void))failureCallback {
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate respondsToSelector:@selector(ensureAddressBookAccessOnSuccess:onFailure:)] ) {
        [delegate ensureAddressBookAccessOnSuccess:successCallback onFailure:failureCallback];
    }
    else {
        [self showErrorMessage:@"Unable to verify access to contacts."];
    }
}

# pragma mark - Contact Picker
- (IBAction)addContact:(id)sender {
    [self ensureAddressBookAccessOnSuccess:^{
        ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
        picker.peoplePickerDelegate = self;

        [picker setDisplayedProperties:
         [NSArray arrayWithObjects:
          [NSNumber numberWithInt:kABPersonEmailProperty],
          [NSNumber numberWithInt:kABPersonPhoneProperty],
          nil
          ]
         ];
        [self presentViewController:picker animated:YES completion:nil];
    }
    onFailure:^{
        [self showErrorMessage:@"Enable contact access under Phone Settings to add contacts."];
    }
    ];

}

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


// PRE IOS 8
- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

// PRE IOS 8
- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    [self peoplePickerNavigationController:peoplePicker
                           didSelectPerson:person
                                  property:property
                                identifier:identifier
    ];

    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

// IOS 8+

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
                         didSelectPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {

    NSString * fullName;
    if ( property != kABPersonPhoneProperty && property != kABPersonEmailProperty ) {
        fullName = [self getFullNameForPerson:person];
        NSLog(@"Attempted to add invalid property %d for contact %@", property, fullName);
    }
    else if ( ABRecordGetRecordID(person) == kABRecordInvalidID ) {
        fullName = [self getFullNameForPerson:person];
        NSLog(@"Attempted to add invalid contact %@: %@", fullName, person);
    }
    else {

        // TODO: allow both at once? See
        // http://stackoverflow.com/questions/1320931/how-to-correctly-use-abpersonviewcontroller-with-abpeoplepickernavigationcontrol

        [self inductContact:person contactType:property identifier:identifier];
        return;
    }

    [self showErrorMessage:[NSString stringWithFormat:@"There was an error adding %@ to the team", fullName]];
}

- (NSManagedObject*)inductContact:(ABRecordRef)person
        contactType:(ABPropertyID)property
        identifier:(ABMultiValueIdentifier)identifier
{
    NSManagedObject * team      = [self team];
    NSManagedObject * newMember = [self makeMemberFromContact:person forTeam:team withContactMethod:property withIdentifier:identifier];

    if (! newMember) {
        [self showErrorMessage:[
            NSString stringWithFormat:@"There was an error adding %@ to the team", [self getFullNameForPerson:person]]
        ];
    }

    // Subclasses responsible for displaying the new member
    return newMember;
}

- (NSManagedObject*)makeMemberFromContact:(ABRecordRef)person
                                  forTeam:(NSManagedObject *)team
                        withContactMethod:(ABPropertyID)property
                           withIdentifier:(ABMultiValueIdentifier)rawIdentifier
{
    NSString * contactType = nil;

    if ( ABRecordGetRecordID(person) == kABRecordInvalidID ) {
        NSLog(@"Attempted to add invalid contact %@: %@", [self getFullNameForPerson:person], person);
        return nil;
    }
    else if ( property == kABPersonEmailProperty ) {
        contactType = @"email";
    }
    else if ( property == kABPersonPhoneProperty ) {
        contactType = @"phoneNumber";
    }
    else {
        NSLog(@"Attempted to add invalid property %d for contact %@", property, [self getFullNameForPerson:person]);
        return nil;
    }

    NSManagedObject * teamAlertContact = [self _findTeamAlertContactForABContact:person];
    if ( !teamAlertContact ) {
        teamAlertContact = [self _createTeamAlertContactFromABContact:person];
    }

    ABMultiValueRef phonesOrEmails = ABRecordCopyValue(person, property);

    NSString * contactInfo = nil;
    NSString * label       = nil;

    if (ABMultiValueGetCount(phonesOrEmails) > 0) {
        contactInfo = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phonesOrEmails, rawIdentifier);
        label       = (__bridge_transfer NSString*) ABMultiValueCopyLabelAtIndex(phonesOrEmails, rawIdentifier);
    }
    else {
        NSLog(@"Could not find %@ for contact %@: %@", contactType, [self getFullNameForPerson:person], person);
        return nil;
    }

    NSNumber * identifier = [NSNumber numberWithInt:rawIdentifier];

    CFRelease(phonesOrEmails);

    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest         *request = [NSFetchRequest fetchRequestWithEntityName:@"ContactInfo"];

    NSPredicate * predicate = [NSPredicate
        predicateWithFormat:@"%K = %@ AND %K = %@ AND %K = %@",
            @"identifier",  identifier,
            @"contactType", contactType,
            @"contact",     teamAlertContact
    ];
    [request setPredicate:predicate];
    [request setFetchLimit:1];

    NSError * error;
    NSArray * contactInfoArray = [context executeFetchRequest:request error:&error];
    if ( error ) {
        NSLog(@"Cannot Retrieve Contact Info! %@ %@", error, [error localizedDescription]);
        return nil;
    }

    NSManagedObject * contactInfoEntity;
    NSArray         * membershipArray = nil;
    if ( [contactInfoArray count] ) {
        contactInfoEntity = [contactInfoArray objectAtIndex:0];

        NSString * existingContactInfo = [contactInfoEntity valueForKey:@"contactInfo"];
        if ( ! [existingContactInfo isEqualToString:contactInfo] ) {
            // This should NEVER happen once contact syncing is a thing
            NSLog(@"Got unexpected %@ (%@), was expecting %@ for contact %@: %@",
                  contactType,
                  contactInfo,
                  existingContactInfo,
                  [self getFullNameForPerson:person],
                  person
            );
            return nil;
        }

        NSEntityDescription * membershipEntityDescription = [NSEntityDescription entityForName:@"Membership"
                                                                        inManagedObjectContext:context];

        NSFetchRequest * membershipRequest = [[NSFetchRequest alloc] init];
        NSPredicate    * membershipPredicate = [NSPredicate predicateWithFormat:@"%K = %@ AND %K = %@",
                                                @"contactInfo", contactInfoEntity,
                                                @"team",        team
                                                ];

        [membershipRequest setEntity:membershipEntityDescription];
        [membershipRequest setPredicate:membershipPredicate];
        [membershipRequest setFetchLimit:1];

        membershipArray = [context executeFetchRequest:membershipRequest error:&error];

        if ( error ) {
            NSLog(@"Cannot Retrieve Membership! %@ %@", error, [error localizedDescription]);
            return nil;
        }
    }
    else {
        contactInfoEntity = [NSEntityDescription insertNewObjectForEntityForName:@"ContactInfo" inManagedObjectContext:context];

        [contactInfoEntity setValue:identifier       forKey:@"identifier"];
        [contactInfoEntity setValue:contactType      forKey:@"contactType"];
        [contactInfoEntity setValue:teamAlertContact forKey:@"contact"];

        // We *could* do these two updates for existing contacts as well
        // But those will be covered by syncing!
        [contactInfoEntity setValue:contactInfo forKey:@"contactInfo"];
        [contactInfoEntity setValue:label       forKey:@"label"];
    }

    // We actually need to do something
    if ( ![membershipArray count] ) {
        NSManagedObject *newMembership = [NSEntityDescription insertNewObjectForEntityForName:@"Membership" inManagedObjectContext:context];
        [newMembership setValue:team              forKey:@"team"];
        [newMembership setValue:contactInfoEntity forKey:@"contactInfo"];
    }

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


# pragma mark - error display
-(void) showErrorMessage:(NSString *)message {
    UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:message
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
    [warningAlert show];
}

-(NSString *) getFullNameForPerson:(ABRecordRef)person {
    NSString * firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString * lastName  = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    return [self _getFullNameFromFirstName:firstName lastName:lastName];
}

-(NSString *) getFullNameForContact:(NSManagedObject *)contact {

    // Note we don't normalize these on input
    // Because we use them to keep contact info up to date
    return [self _getFullNameFromFirstName:[contact valueForKey:@"firstName"] lastName:[contact valueForKey:@"lastName"]];

}

-(NSString *)_getFullNameFromFirstName:(NSString *)firstName lastName:(NSString *)lastName {
    NSMutableString * fullName = [[NSMutableString alloc] init];
    if ( firstName != nil ) {
        [fullName setString:firstName];
        if ( lastName != nil ) {
            [fullName appendFormat:@" %@", lastName];
        }
    }
    else if ( lastName != nil ) {
        [fullName setString:lastName];
    }

    return [NSString stringWithString:fullName];
}

@end
