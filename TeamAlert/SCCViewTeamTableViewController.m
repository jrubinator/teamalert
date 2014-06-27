//
//  SCCViewTeamTableViewController.m
//  TeamAlert
//
//  Created by Jonathan Rubin on 6/26/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import "SCCViewTeamTableViewController.h"

@interface SCCViewTeamTableViewController ()
@property (strong) NSManagedObject * team;

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

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    self.team    = team;
    self.members = [NSMutableArray arrayWithArray:[[team valueForKey:@"contacts"] allObjects]];
}

@end
