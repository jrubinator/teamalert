//
//  SCCNewTeamTableViewController.m
//  TeamAlert
//
//  Created by Jonathan Rubin on 6/1/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import "SCCNewTeamTableViewController.h"

@interface SCCNewTeamTableViewController ()

@end

@implementation SCCNewTeamTableViewController

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
    
    // Monitor the name field so we know when the team can be saved
    [[self teamNameTextField] addTarget:self
                                action:@selector(maybeEnableDoneButton)
                      forControlEvents:UIControlEventEditingChanged];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // We'll also need to check when contacts are removed, but hey!
    self.navigationItem.rightBarButtonItem.enabled = [self isTeamSaveable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Adding a contact
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

- (void)inductContact:(ABRecordRef)person
{
    NSManagedObject * newMember = [self makeMemberFromContact:person];
    
    if ( ![self members] ) {
        self.members = [[NSMutableArray alloc] init];
    }

    [[self members] addObject:newMember];

    [[self tableView] reloadData];
    
}

- (NSManagedObject*)makeMemberFromContact:(ABRecordRef)person
{
    NSNumber * recordID = [NSNumber numberWithInt:ABRecordGetRecordID(person)];
    NSString * firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString * lastName  = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
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
    
    NSManagedObject *newMember = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];

    [newMember setValue:recordID  forKey:@"recordID"];
    [newMember setValue:firstName forKey:@"firstName"];
    [newMember setValue:lastName  forKey:@"lastName"];

    NSManagedObject *newPhoneMembership = [NSEntityDescription insertNewObjectForEntityForName:@"Membership" inManagedObjectContext:context];

    [newPhoneMembership setValue:phone          forKey:@"contactInfo"];
    [newPhoneMembership setValue:@"phoneNumber" forKey:@"contactType"];
    [newPhoneMembership setValue:newMember      forKey:@"contact"];

    NSManagedObject *newEmailMembership = [NSEntityDescription insertNewObjectForEntityForName:@"Membership" inManagedObjectContext:context];

    [newEmailMembership setValue:email     forKey:@"contactInfo"];
    [newEmailMembership setValue:@"email"  forKey:@"contactType"];
    [newEmailMembership setValue:newMember forKey:@"contact"];
    
    return newMember;
}

- (void)maybeEnableDoneButton
{
    self.navigationItem.rightBarButtonItem.enabled = [self isTeamSaveable];
}

- (BOOL)isTeamSaveable
{
    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
    // All you need is love, or in this case, members and a name
    return
        [self.members count] > 0 &&
        [[self.teamNameTextField.text stringByTrimmingCharactersInSet:whitespaceSet] length] > 0;
}

- (IBAction)saveTeam:(id)sender {
    // This should always be true
    if( [self isTeamSaveable] ) {
        NSString *teamName = self.teamNameTextField.text;
        NSManagedObjectContext *context = [self managedObjectContext];

        NSManagedObject *newTeam = [NSEntityDescription insertNewObjectForEntityForName:@"Team" inManagedObjectContext:context];
        [newTeam setValue:teamName forKey:@"name"];

        for (NSManagedObject *member in self.members) {
            for (NSManagedObject *membership in [member valueForKey:@"memberships"]) {
                [membership setValue:newTeam forKey:@"team"];
            }
        }

        NSError *saveError = nil;
        if (![context save:&saveError]) {
            NSLog(@"Could not save new team: %@, %@", saveError, [saveError localizedDescription]);
        }

        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        NSLog(@"An attempt was made to save a new team from an unexpected state");
    }

}

@end
