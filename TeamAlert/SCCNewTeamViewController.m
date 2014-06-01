//
//  SCCNewTeamViewController.m
//  TeamAlert
//
//  Created by Jonathan Rubin on 5/29/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import "SCCNewTeamViewController.h"

@interface SCCNewTeamViewController ()
@property (strong) NSMutableArray * members;

@end

@implementation SCCNewTeamViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    
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

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)] ) {
        context = [delegate managedObjectContext];
    }
    return context;
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
    [[self members] addObject:newMember];
    
}

- (NSManagedObject*)makeMemberFromContact:(ABRecordRef)person
{
    NSNumber * recordID = [NSNumber numberWithInt:ABRecordGetRecordID(person)];
    NSLog(@"make");
    NSString * firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString * lastName  = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString * phone = nil;
    NSString * email = nil;
    NSLog(@"phones");
    ABMultiValueRef phoneNumbers   = ABRecordCopyValue(person, kABPersonPhoneProperty);
    ABMultiValueRef emailAddresses = ABRecordCopyValue(person, kABPersonEmailProperty);

    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    }
    
    if (ABMultiValueGetCount(emailAddresses) > 0) {
        email = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(emailAddresses, 0);
    }
    NSLog(@"release");
    CFRelease(phoneNumbers);
    CFRelease(emailAddresses);
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSLog(@"get");
    
    NSManagedObject *newMember = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
    NSLog(@"contact");
    [newMember setValue:recordID  forKey:@"recordID"];
    [newMember setValue:firstName forKey:@"firstName"];
    [newMember setValue:lastName  forKey:@"lastName"];
    NSLog(@"member");
    
    NSManagedObject *newMembership = [NSEntityDescription insertNewObjectForEntityForName:@"Membership" inManagedObjectContext:context];
    [newMembership setValue:phone     forKey:@"phoneNumber"];
    [newMembership setValue:email     forKey:@"email"];
    NSLog(@"contact set");
    [newMembership setValue:newMember forKey:@"contact"];
    
    
    return newMember;
}

@end
