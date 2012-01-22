//
//  ViewEventViewController.m
//  ClubMaster
//
//  Created by Henrik Hansen on 18/01/12.
//

#import "ViewEventViewController.h"
#import "TableCellEvent.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation ViewEventViewController

@synthesize tableView;
@synthesize data;
@synthesize isAttending;
@synthesize attendingButton, unattendingButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"View team", @"");

    NSLog(@"data %@", data);

    if (isAttending) {
        [attendingButton setHidden:YES];
    } else {
        [unattendingButton setHidden:YES];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tw numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    TableCellEvent *cell = [tw dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TableCellEvent alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    if (indexPath.row == 0) {
        cell.primaryLabel.text = NSLocalizedString(@"Date", @"");
        cell.secondaryLabel.text = [data objectForKey:@"first_date"];
    } else if (indexPath.row == 1) {
        cell.primaryLabel.text = NSLocalizedString(@"Time", @"");
        cell.secondaryLabel.text = [data objectForKey:@"first_date"];        
    } else if (indexPath.row == 2) {
        cell.primaryLabel.text = NSLocalizedString(@"Club", @"");
        cell.secondaryLabel.text = [data objectForKey:@"xxxxx"];
    } else if (indexPath.row == 3) {
        cell.primaryLabel.text = NSLocalizedString(@"Instructor", @"");
        NSArray *instructors = [data objectForKey:@"instructors"];
        if ([instructors count]) {
            cell.secondaryLabel.text = [instructors componentsJoinedByString:@", "];
        } else {
            cell.secondaryLabel.text = @"";
        }
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tw titleForHeaderInSection:(NSInteger)section
{
    return @"Team details";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (IBAction)attend:(id)sender
{
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSLog(@"url %@", [NSString stringWithFormat:kAttendTeam, [preferences valueForKey:@"serverurl"], [data objectForKey:@"id"]]);
    ASIFormDataRequest *requestUserRegistrations = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kAttendTeam, [preferences valueForKey:@"serverurl"], [data objectForKey:@"id"]]]];
    [requestUserRegistrations setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    [requestUserRegistrations startSynchronous];

    NSError *error = [requestUserRegistrations error];
    NSLog(@"status code %d", [requestUserRegistrations responseStatusCode]);
    if (!error) {
        if ([requestUserRegistrations responseStatusCode] == 200) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attend Success", @"")
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];

            [unattendingButton setHidden:NO];
            [attendingButton setHidden:YES];            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attend failed", @"")
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server fail", @"")
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (IBAction)unattend:(id)sender
{
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];

    ASIFormDataRequest *requestUserRegistrations = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kUnattendTeam, [preferences valueForKey:@"serverurl"], [data objectForKey:@"id"]]]];
    [requestUserRegistrations setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    [requestUserRegistrations startSynchronous];

    NSError *error = [requestUserRegistrations error];

    if (!error) {
        if ([requestUserRegistrations responseStatusCode] == 200) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unattend Success", @"")
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            [attendingButton setHidden:NO];
            [unattendingButton setHidden:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unattend failed", @"")
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server fail", @"")
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

@end
