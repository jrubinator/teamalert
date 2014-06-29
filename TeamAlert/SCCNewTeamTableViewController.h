//
//  SCCNewTeamTableViewController.h
//  TeamAlert
//
//  Created by Jonathan Rubin on 6/1/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//


#import "SCCTeamTableViewController.h"

@interface SCCNewTeamTableViewController : SCCTeamTableViewController


- (IBAction)saveTeam:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *teamNameTextField;

@end
