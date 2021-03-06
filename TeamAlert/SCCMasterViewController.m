//
//  SCCMasterViewController.m
//  TeamAlert
//
//  Created by Jonathan Rubin on 4/26/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import "SCCMasterViewController.h"

#import "SCCDetailViewController.h"
#import "SCCPaddedTableViewCell.h"
#import "SCCDebug.h"

@interface SCCMasterViewController () {
    NSMutableArray *_teams;
    NSManagedObject *_selectedTeam;
}
@end

const int kEMAIL_ACTION_INDEX = 0;
const int kPHONE_ACTION_INDEX = 1;

@implementation SCCMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

#pragma mark - Cell Display
- (void)viewDidLoad
{
    [super viewDidLoad];

    // This is what looks good
    [self.tableView setRowHeight:54.0f];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // Every section represents a team
    // And every team needs some separation (margins)
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
    _teams = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];

    // Provide extra link to create first team
    [self.firstTeamView setHidden:[_teams count]];

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
    return _teams.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCCPaddedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSManagedObject *team = _teams[indexPath.section];
    cell.textLabel.text = [team valueForKey:@"name"];

    if ( cell.accessoryView == nil ) {
        cell.accessoryView        = [[SCCAlertButton alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
        cell.accessoryView.opaque = NO;
        cell.backgroundColor      = [UIColor clearColor];

        [(SCCAlertButton*)cell.accessoryView addTarget:self action:@selector(sendAlert:) forControlEvents:UIControlEventTouchUpInside];
    }

    [cell.accessoryView setTag:indexPath.section];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete an object form the database
        NSManagedObject *team = [_teams objectAtIndex:indexPath.section];
        if ( [self deleteTeam:team]) {
            // And delete it from the UI
            [_teams removeObjectAtIndex:indexPath.section];
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];

            // Provide extra link to create first team
            [self.firstTeamView setHidden:[_teams count]];
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
        NSDate *team = _teams[indexPath.section];
        self.detailViewController.detailItem = team;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        self.navigationItem.backBarButtonItem = [
            [UIBarButtonItem alloc] initWithTitle:@"All Teams"
                                            style:UIBarButtonItemStylePlain
                                           target:nil
                                           action:nil
        ];

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *team = _teams[indexPath.section];
        [[segue destinationViewController] setDetailItem:team];
    }
}

# pragma mark - UIActionSheetDelegate

-(void)sendAlert:(id)sender {
    UIButton *senderButton = (UIButton *)sender;

    _selectedTeam       = [_teams objectAtIndex:senderButton.tag];
    NSString * teamName = [_selectedTeam valueForKeyPath:@"name"];
    NSString * emailOpt = [NSString stringWithFormat:@"Email %@ Team", teamName];
    NSString * phoneOpt = [NSString stringWithFormat:@"Text %@ Team", teamName];

    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:emailOpt, phoneOpt, nil
                             ];
    sheet.actionSheetStyle = UIActionSheetStyleDefault;
    [sheet showInView:[self view]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case kPHONE_ACTION_INDEX:
            [self sendTextToTeam:_selectedTeam];
            break;
        case kEMAIL_ACTION_INDEX:
            [self sendEmailToTeam:_selectedTeam];
            break;
        default:
            break;
    }
    _selectedTeam = nil;
}

# pragma mark MFMessageComposeViewControllerDelegate

- (void)sendTextToTeam:(NSManagedObject *)team {
    if(![MFMessageComposeViewController canSendText]) {
        // TODO Don't even get to this point
        [self showErrorMessage:@"This device does not support text messages!"];
        return;
    }

    MFMessageComposeViewController * composer = [[MFMessageComposeViewController alloc] init];

    composer.messageComposeDelegate = self;
    composer.recipients = [[team valueForKey:@"phoneNumbers"] valueForKey:@"contactInfo"];

    if( ![composer.recipients count] ) {
        // TODO Don't even get to this point
        [self showErrorMessage:@"This team has no one with phone numbers!"];
        return;
    }
    
    composer.body = [NSString stringWithFormat:@"%@:\n", [team valueForKey:@"name"]];

    [self presentViewController:composer animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if ( result == MessageComposeResultFailed ) {
        // The UI is covered by the message app, which displays an appropriate banner message
        DLog(@"Failed to send text");
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendEmailToTeam:(NSManagedObject *)team {
    if(![MFMailComposeViewController canSendMail]) {
        // TODO Don't even get to this point
        [self showErrorMessage:@"This device does not support phone numbers!"];
        return;
    }

    NSArray * recipients = [[team valueForKey:@"emails"] valueForKey:@"contactInfo"];

    if( ![recipients count] ) {
        // TODO Don't even get to this point
        [self showErrorMessage:@"This team has no one with email addresses!"];
        return;
    }

    MFMailComposeViewController * composer = [[MFMailComposeViewController alloc] init];
    composer.mailComposeDelegate = self;
    [composer setToRecipients:recipients];
    [composer setSubject:[NSString stringWithFormat:@"%@ Alert!", [team valueForKey:@"name"]]];

    [self presentViewController:composer animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if ( result == MFMailComposeResultFailed || error != nil ) {
        NSLog( @"Failed to send email with error: %@, %@", error, [error localizedDescription]);
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - Managed Objects

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

        // Delete contactInfo if it's only used for this team
        NSManagedObject *contactInfo = [membership valueForKey:@"contactInfo"];
        if ( [[contactInfo valueForKey:@"memberships"] count] == 1 ) {
            [context deleteObject:contactInfo];
        }
    }

    [context deleteObject:team];

    NSError *error = nil;
    if ( ![context save:&error] ) {
        NSLog(@"Cannot delete team! %@ %@", error, [error localizedDescription]);
        return NO;
    }

    return YES;
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

@end
