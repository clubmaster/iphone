//
//  ViewTeamViewController.m
//  ClubMaster
//
//  Created by Henrik Hansen on 18/01/12.
//

#import "ViewTeamViewController.h"
#import "TableCellDetail.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "ISO8601DateFormatter.h"

@implementation ViewTeamViewController

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

    self.tableView = nil;
    self.attendingButton = nil;
    self.unattendingButton = nil;
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
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    TableCellDetail *cell = [tw dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[TableCellDetail alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    if (indexPath.row == 0) {
        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        NSDate *theDate = [formatter dateFromString:[data objectForKey:@"first_date"]];
        [formatter release], formatter = nil;

        NSDateFormatter *df = [[NSDateFormatter alloc] init];

        [df setDateFormat:@"dd MMM yyyy"];
        NSString *date = [NSString stringWithFormat:@"%@", [df stringFromDate:theDate]];

        [df release];

        cell.primaryLabel.text = NSLocalizedString(@"Date", @"");
        cell.secondaryLabel.text = [NSString stringWithFormat:@"%@", date];
    } else if (indexPath.row == 1) {
        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        NSDate *theDate = [formatter dateFromString:[data objectForKey:@"first_date"]];
        [formatter release], formatter = nil;

        NSDateFormatter *df = [[NSDateFormatter alloc] init];

        [df setDateFormat:@"HH:mm"];
        NSString *date = [NSString stringWithFormat:@"%@", [df stringFromDate:theDate]];

        [df release];

        cell.primaryLabel.text = NSLocalizedString(@"Time", @"");
        cell.secondaryLabel.text = date;        
    } else if (indexPath.row == 2) {
        cell.primaryLabel.text = NSLocalizedString(@"Level", @"");
        cell.secondaryLabel.text = [data objectForKey:@"level"];
    } else if (indexPath.row == 3) {
        cell.primaryLabel.text = NSLocalizedString(@"Club", @"");
        cell.secondaryLabel.text = @"";
    } else if (indexPath.row == 4) {
        cell.primaryLabel.text = NSLocalizedString(@"Instructor(s)", @"");

        NSArray *instructors = [data objectForKey:@"instructors"];

        if ([instructors count]) {
            NSMutableArray *instructorsArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [instructors count]; i++) {
                [instructorsArray addObject:[NSString stringWithFormat:@"%@ %@", [[instructors objectAtIndex:i] objectForKey:@"first_name"], [[instructors objectAtIndex:i] objectForKey:@"last_name"]]];                
            }

            cell.secondaryLabel.text = [instructorsArray componentsJoinedByString:@", "];

            [instructorsArray release];
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
    ASIFormDataRequest *requestAttend = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kAttendTeam, [preferences valueForKey:@"serverurl"], [data objectForKey:@"id"]]]];
    [requestAttend setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    [requestAttend startSynchronous];

    NSError *error = [requestAttend error];
    NSLog(@"status code %d", [requestAttend responseStatusCode]);
    NSLog(@"return string %@", [requestAttend responseString]);

    if (!error) {
        if ([requestAttend responseStatusCode] == 200) {
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
            NSData *jsonData = [requestAttend responseData];
            NSString *errorMsg = [[jsonData objectFromJSONData] objectForKey:@"error_msg"];

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMsg
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

-(void) dealloc
{
    [data release];

    [super dealloc];
}

@end
