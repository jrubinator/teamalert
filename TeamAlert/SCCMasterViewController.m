//
//  SCCMasterViewController.m
//  TeamAlert
//
//  Created by Jonathan Rubin on 4/26/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import "SCCMasterViewController.h"

#import "SCCDetailViewController.h"

@interface SCCMasterViewController () {
    NSMutableArray *_teams;
}
@end

@implementation SCCMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Not sure why our other Table View Controllers don't need this...
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    // A little extra margin before the first cell
    UIEdgeInsets inset    = [self.tableView contentInset];
    CGFloat      insetTop = inset.top;
    if ( !insetTop ) { insetTop = 5.0f; }
    [self.tableView setContentInset:UIEdgeInsetsMake(insetTop * 1.5f, inset.left, inset.bottom, inset.right)];

	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
/* Un-comment to do default app navigation
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
 */
    self.detailViewController = (SCCDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
    _teams = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _teams.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSManagedObject *team = _teams[indexPath.row];
    cell.textLabel.text = [team valueForKey:@"name"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Default is 44.0f, this is 65.0f
    return [super tableView:tableView heightForRowAtIndexPath:indexPath] * 1.5f;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete an object form the database
        NSManagedObject *team = [_teams objectAtIndex:indexPath.row];
        if ( [self deleteTeam:team]) {
            // And delete it from the UI
            [_teams removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDate *team = _teams[indexPath.row];
        self.detailViewController.detailItem = team;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *team = _teams[indexPath.row];
        [[segue destinationViewController] setDetailItem:team];
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (BOOL)deleteTeam:(NSManagedObject *)team {

    NSManagedObjectContext *context = [self managedObjectContext];

    for ( NSManagedObject *contact in [team valueForKey:@"contacts"] ) {
        // Delete the contact if they have no other teams
        if ( [[contact valueForKey:@"teams"] count] == 1 ) {
            [context deleteObject:contact];
        }
    }

    for ( NSManagedObject *membership in [team valueForKey:@"memberships"] ) {

        [context deleteObject:membership];
    }

    [context deleteObject:team];

    NSError *error = nil;
    if ( ![context save:&error] ) {
        NSLog(@"Cannot Delete! %@ %@", error, [error localizedDescription]);
        return NO;
    }

    return YES;
}

@end
