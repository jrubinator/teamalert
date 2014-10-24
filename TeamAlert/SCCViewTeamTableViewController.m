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

- (NSDate *) lastSyncedWithAddressBook {
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate respondsToSelector:@selector(lastSyncedWithAddressBook)] ) {
        return (NSDate *) [delegate performSelector:@selector(lastSyncedWithAddressBook)];
    }
    return nil;
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
        if ( [self deleteContact:contact fromTeam:self.team]) {
            // And delete it from the UI
            [self.members removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            [self showErrorMessage:[
                NSString stringWithFormat:@"Something went wrong deleting %@", [self getFullNameForContact:contact]
            ]];
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
    [self syncTeam:team];
    // Make sure the team is up to date
    [[self managedObjectContext] refreshObject:team mergeChanges:NO];

    self.team    = team;
    self.members = [NSMutableOrderedSet orderedSetWithArray:[[team valueForKey:@"contacts"] allObjects]];
}

# pragma mark - Contact Handling

- (NSManagedObject*)inductContact:(ABRecordRef)person
                      contactType:(ABPropertyID)property
                       identifier:(ABMultiValueIdentifier)identifier
{
    NSManagedObject * newMember = [super inductContact:person contactType:property identifier:identifier];

    NSManagedObjectContext * context   = [self managedObjectContext];
    NSError                * saveError = nil;

    if (![context save:&saveError]) {
        [self showErrorMessage:@"Something went wrong saving your team."];
        NSLog(@"Could not save team: %@, %@", saveError, [saveError localizedDescription]);
    }
    else {
        [self displayMember:newMember];
    }

    return newMember;
}

# pragma mark - Things That Should Really Be In A Team Object

- (BOOL)deleteContact:(NSManagedObject *)contact fromTeam:(NSManagedObject *)team {

    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Membership"
                                                                  inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];

    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"(team = %@) AND (contactInfo.contact = %@)", team, contact];
    [request setPredicate:predicate];

    NSError *contextError;
    NSArray *contactMemberships = [context executeFetchRequest:request error:&contextError];
    if (contactMemberships == nil)
    {
        NSLog(@"Maybe that contact wasn't associated with this team? Error: %@ (%@)", contextError, [contextError localizedDescription]);
    }
    else {
        if ( [[contact valueForKey:@"teams"] count] == 1 ) {
            [context deleteObject:contact];
        }

        for (NSManagedObject *membership in contactMemberships) {
            [context deleteObject:membership];

            NSManagedObject *contactInfo = [membership valueForKey:@"contactInfo"];
            if ( [[contactInfo valueForKey:@"memberships"] count] == 1 ) {
                [context deleteObject:contactInfo];
            }
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

- (void)syncTeam:(NSManagedObject *)team {
    if ( ![self canAccessAddressBook] ) {
        // No point in trying to sync
        return;
    }

    NSManagedObjectContext * context = [self managedObjectContext];
    [context refreshObject:team mergeChanges:NO];

    NSDate * appLastSynced  = [self lastSyncedWithAddressBook];
    NSDate * teamLastSynced = [team valueForKey:@"lastSynced"];

    // Synced as recently as we need
    if ( appLastSynced && teamLastSynced && [appLastSynced compare:teamLastSynced] == NSOrderedAscending ) {
        return;
    }

    ABAddressBookRef addressBook = [self addressBook];

    // Match 'em
    for (NSManagedObject * contact in [team valueForKey:@"contacts"]) {
        NSDate * contactLastSynced = [contact valueForKey:@"lastSynced"];
        if ( appLastSynced && contactLastSynced && [appLastSynced compare:contactLastSynced] == NSOrderedAscending ) {
            continue;
        }

        NSNumber * recordID = [contact valueForKey:@"recordID"];
        ABRecordRef contactRecord = ABAddressBookGetPersonWithRecordID(addressBook, [recordID intValue]);

        // Okay, they exist. Retain the reference.
        if ( contactRecord ) {
            contactRecord = CFRetain(contactRecord);
        }
        // Uh oh, something changed. Try to use name instead
        else {
            NSString * fullName = [self getFullNameForContact:contact];

            NSArray * deviceContacts =
                (__bridge_transfer NSArray *)ABAddressBookCopyPeopleWithName(
                    addressBook,
                    // This appears to be blind to name-order, and spaces
                    (__bridge CFStringRef) [fullName copy]
                );

            // If none were found, this loop is skipped and the contact is deleted.
            // Otherwise find a matching contact
            for (int i = 0; i < [deviceContacts count]; i++) {
                ABRecordRef person = (__bridge ABRecordRef)([deviceContacts objectAtIndex:i]);
                ABMultiValueRef phoneNumbers    = nil;
                ABMultiValueRef emails          = nil;
                for ( NSManagedObject * contactInfoEntity in [contact valueForKey:@"contactInfos"] ) {
                    NSString * contactType = [contactInfoEntity valueForKey:@"contactType"];
                    if ( [contactType isEqualToString:@"email"] ) {
                        if ( emails == nil ) { emails = ABRecordCopyValue(person, kABPersonEmailProperty); }
                        ABMultiValueIdentifier identifier = [[contactInfoEntity valueForKey:@"identifier"] intValue];
                        CFIndex  index     = ABMultiValueGetIndexForIdentifier(emails, identifier);
                        NSString * anEmail = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(emails, index);

                        if ( [[contactInfoEntity valueForKey:@"contactInfo"] isEqualToString:anEmail] ) {
                            contactRecord = person;
                        }
                        else {
                            // identifier did not match
                            // We're going to be really sure this is the cont
                            for (CFIndex index = 0; index < ABMultiValueGetCount(emails); index++) {
                                NSString *anEmail = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(emails, index);
                                if ( [[contactInfoEntity valueForKey:@"contactInfo"] isEqualToString:anEmail] ) {
                                    if ( contactRecord ) {
                                        // TODO: Prompt the user!
                                        NSLog(@"Multiple contacts match email for %@: %@", fullName, anEmail);
                                    }
                                    else {
                                        contactRecord = person;
                                    }
                                    // Seems to match, back to outer for loop
                                    break;
                                }
                            }
                        }
                    }
                    else if ( [contactType isEqualToString:@"phoneNumber"] ) {
                        if ( phoneNumbers == nil ) { phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty); }
                        ABMultiValueIdentifier identifier = [[contactInfoEntity valueForKey:@"identifier"] intValue];
                        CFIndex  index   = ABMultiValueGetIndexForIdentifier(phoneNumbers, identifier);
                        NSString *aPhone = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phoneNumbers, index);

                        if ( [[contactInfoEntity valueForKey:@"contactInfo"] isEqualToString:aPhone] ) {
                            contactRecord = person;
                        }
                        else {
                            // identifier did not match
                            // We're going to be really sure this is the cont
                            for (CFIndex index = 0; index < ABMultiValueGetCount(phoneNumbers); index++) {
                                NSString *aPhone = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phoneNumbers,index);
                                if ( [[contactInfoEntity valueForKey:@"contactInfo"] isEqualToString:aPhone] ) {
                                    if ( contactRecord ) {
                                        // TODO: Prompt the user!
                                        NSLog(@"Multiple contacts match phone # for %@: %@", fullName, aPhone);
                                    }
                                    else {
                                        contactRecord = person;
                                    }
                                    // Seems to match, back to outer for loop
                                    break;
                                }
                            }
                        }
                    }
                }

                // Did not match, release
                if ( person != contactRecord ) {
                    CFRelease(person);
                }
            }
        }

        if ( contactRecord ) {
            [self syncContact:contact withABRecord:contactRecord];
            CFRelease( contactRecord );
        }
        else {
            // As below, we may need to display the contact as deleted from other teams one day

            NSLog(@"Could not sync %@; deleting", contact);
            [self showErrorMessage:[NSString stringWithFormat:@"Contact %@ appears to have been removed from your device, and will also be removed from TeamMail", [self getFullNameForContact:contact]
            ]];

            for ( NSManagedObject * contactInfoEntity in [contact valueForKey:@"ContactInfos"] ) {
                for ( NSManagedObject * membership in [contactInfoEntity valueForKey:@"Memberships"] ) {
                    [context deleteObject:membership];
                }
                [context deleteObject:contactInfoEntity];
            }
            [context deleteObject:contact];
        }
    }

    [team setValue:[NSDate date] forKey:@"lastSynced"];
    NSError * error = nil;
    [context save:&error];
    if ( error ) {
        NSLog(@"Error syncing team: %@, %@", error, [error localizedDescription]);
        [context rollback];
    }
}

- (void)syncContact:(NSManagedObject *)contact withABRecord:(ABRecordRef)record {

    NSDate * modifyDate = (__bridge_transfer NSDate *)ABRecordCopyValue(record, kABPersonModificationDateProperty);
    // Contact hasn't change since the contact last synced
    if ( [(NSDate *)[contact valueForKey:@"lastSynced"] compare:modifyDate] == NSOrderedDescending ) {
        [contact setValue:[NSDate date] forKey:@"lastSynced"];
        return;
    }

    int numberDeleted = 0;
    NSManagedObjectContext * context = [self managedObjectContext];

    NSArray * contactInfos = [contact valueForKey:@"contactInfos"];
    for (NSManagedObject * contactInfoEntity in contactInfos){
        NSString * contactType = [contactInfoEntity valueForKey:@"contactType"];
        NSString * contactInfo = [contactInfoEntity valueForKey:@"contactInfo"];
        NSString * label       = [contactInfoEntity valueForKey:@"label"];

        ABPropertyID propertyID;
        if ( [contactType isEqualToString:@"phoneNumber"] ) {
            propertyID = kABPersonPhoneProperty;
        }
        else {
            propertyID = kABPersonEmailProperty;
        }

        ABMultiValueRef phonesOrEmails     = ABRecordCopyValue(record, propertyID);
        CFIndex         indexOfContactInfo = ABMultiValueGetIndexForIdentifier(phonesOrEmails, [[contactInfoEntity valueForKey:@"identifier"] intValue]);

        NSString * addressContactInfo = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phonesOrEmails,indexOfContactInfo);
        NSString * addressLabel       = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(phonesOrEmails, indexOfContactInfo);
        if ( addressLabel && [addressLabel isEqualToString:label] ) {
            [contactInfoEntity setValue:addressContactInfo forKey:@"contactInfo"];
        }
        else if ( addressContactInfo && [addressContactInfo isEqualToString:contactInfo] ) {
            [contactInfoEntity setValue:addressLabel forKey:@"label"];
        }
        else {
            // Our identifier failed. Try by phone number/email
            indexOfContactInfo = -1;
            for (CFIndex index = 0; index < ABMultiValueGetCount(phonesOrEmails); index++) {
                NSString *aPhoneOrEmail = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phonesOrEmails, index);
                if ( [contactInfo isEqualToString:aPhoneOrEmail] ) {
                    if ( indexOfContactInfo != -1 ) {
                        // TODO: Prompt the user!
                        NSLog(@"Multiple %@s match for %@: %@", contactType, [self getFullNameForContact:contact], aPhoneOrEmail);
                    }
                    else {
                        indexOfContactInfo = index;
                    }
                }
            }

            // No number/email match either? Try by label...
            if ( indexOfContactInfo == -1 ) {
                for (CFIndex index = 0; index < ABMultiValueGetCount(phonesOrEmails); index++) {
                    NSString *aLabel = (__bridge_transfer NSString*) ABMultiValueCopyLabelAtIndex(phonesOrEmails, index);
                    if ( [contactInfo isEqualToString:aLabel] ) {
                        if ( indexOfContactInfo != -1 ) {
                            // TODO: Prompt the user!
                            NSLog(@"Multiple labels match %@ for %@: %@", contactType, [self getFullNameForContact:contact], aLabel);
                        }
                        else {
                            indexOfContactInfo = index;
                        }
                    }
                }
            }

            // Yeeps! Not even a label match! At this point, the phone/email was surely deleted entirely.
            // And we can't find it even if it wasn't, so we'll delete it from TeamAlert.
            if ( indexOfContactInfo == -1 ) {
                NSString * fullName = [self getFullNameForContact:contact];
                NSLog(@"Could not sync %@: %@ for %@; deleting", contactType, contactInfo, fullName);
                [self showErrorMessage:[NSString stringWithFormat:@"Contact %@'s %@ %@ appears to have been removed from your device, and will also be removed from TeamMail",
                    fullName,
                    contactType,
                    contactInfo
                ]];
                for (NSManagedObject * membership in [contactInfoEntity valueForKey:@"memberships"]) {
                    [context deleteObject:membership];
                }
                [context deleteObject:contactInfoEntity];
                numberDeleted++;
            }
            else {
                addressContactInfo = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phonesOrEmails,indexOfContactInfo);
                addressLabel       = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(phonesOrEmails,indexOfContactInfo);
                NSNumber * identifier = [NSNumber numberWithInt:ABMultiValueGetIdentifierAtIndex(phonesOrEmails, indexOfContactInfo)];

                [contactInfoEntity setValue:addressContactInfo forKey:@"contactInfo"];
                [contactInfoEntity setValue:addressLabel       forKey:@"label"];
                [contactInfoEntity setValue:identifier         forKey:@"identifier"];
            }
        }
    }

    if ( [contactInfos count] == numberDeleted ) {
        // No reason to keep the contact around
        // One day we might want to mark in each team that this contact has been removed
        [context deleteObject:contact];
    }
    else {
        [contact setValue:[NSDate date] forKey:@"lastSynced"];
    }

    // NOTE: no sync occurs here! Currently, syncTeam controls this.
}

@end
