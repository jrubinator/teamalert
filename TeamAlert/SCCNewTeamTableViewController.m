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

    // Create a scratchpad team for saving
    NSManagedObjectContext *context = [self managedObjectContext];

    [self setTeam:[NSEntityDescription insertNewObjectForEntityForName:@"Team"
                                       inManagedObjectContext:context]];

    // Monitor the name field so we know when the team can be saved
    [[self teamNameTextField] addTarget:self
                                action:@selector(maybeEnableDoneButton)
                      forControlEvents:UIControlEventEditingChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // We'll also need to check when contacts are removed, but hey!
    self.navigationItem.rightBarButtonItem.enabled = [self isTeamSaveable];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // When the view unloads, discard the scratchpad team

    [super viewWillDisappear:animated];
    // make sure we're not fetching the people picker
    if ( [self isMovingFromParentViewController] ) {
        [[self managedObjectContext] rollback];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Adding a contact

- (void)inductContact:(ABRecordRef)person
{
    NSManagedObject * team      = [self team];
    NSManagedObject * newMember = [self makeMemberFromContact:person forTeam:team];
    
    if ( ![self members] ) {
        self.members = [NSMutableArray arrayWithArray:[[team valueForKey:@"contacts"] allObjects]];
    }
    else
    {
        [[self members] addObject:newMember];
    }

    [[self tableView] reloadData];
    
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
        NSManagedObjectContext *context = [self managedObjectContext];

        [[self team] setValue:self.teamNameTextField.text forKey:@"name"];

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
