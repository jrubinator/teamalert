//
//  SCCViewTeamTableViewController.h
//  TeamAlert
//
//  Created by Jonathan Rubin on 6/26/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import "SCCTeamTableViewController.h"

@interface SCCViewTeamTableViewController : SCCTeamTableViewController

-(void)setDetailItem:(NSManagedObject *)team;
@property (weak, nonatomic) IBOutlet UIView *addContactView;
@property (weak, nonatomic) IBOutlet UIButton *addContact;

@end
