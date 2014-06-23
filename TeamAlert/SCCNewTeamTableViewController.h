//
//  SCCNewTeamTableViewController.h
//  TeamAlert
//
//  Created by Jonathan Rubin on 6/1/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//


#import "SCCTeamTableViewController.h"

@interface SCCNewTeamTableViewController : SCCTeamTableViewController <ABPeoplePickerNavigationControllerDelegate>
- (IBAction)addContact:(id)sender;
- (IBAction)saveTeam:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *teamNameTextField;

@end
