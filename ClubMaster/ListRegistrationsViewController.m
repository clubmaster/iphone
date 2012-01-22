//
//  FirstViewController.m
//  ClubMaster
//
//  Created by Henrik Hansen on 15/11/11.
//

#import "ListRegistrationsViewController.h"
#import "ViewTeamViewController.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "TableCellEventList.h"
#import "ISO8601DateFormatter.h"

@interface ListRegistrationsViewController ()
- (void)loadEventsFromLogin;
@end

@implementation ListRegistrationsViewController

@synthesize tableView;
@synthesize registrations;
@synthesize upcomingEvents;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Teams", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"registrations"];
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

    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.tableView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadEventsFromLogin) name:@"loadEventsFromLogin" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self loadEventsFromLogin];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

    //[[NSNotificationCenter defaultCenter] removeObserver:@"loadEventsFromLogin"];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tw numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [registrations count];
    } else {
        return [upcomingEvents count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    TableCellEventList *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TableCellEventList alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        NSDictionary *data = [registrations objectAtIndex:indexPath.row];
        cell.primaryLabel.text = [data objectForKey:@"team_name"];
        cell.secondaryLabel.text = [data objectForKey:@"description"];

        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        NSDate *theDate = [formatter dateFromString:[data objectForKey:@"first_date"]];
        [formatter release], formatter = nil;

        NSDateFormatter *df = [[NSDateFormatter alloc] init];

        [df setDateFormat:@"dd MMM yyyy HH:mm"];
        NSString *date = [NSString stringWithFormat:@"%@", [df stringFromDate:theDate]];

        cell.thirdLabel.text = [NSString stringWithFormat:@"%@", date];

        [df release];
    } else {
        NSDictionary *data = [upcomingEvents objectAtIndex:indexPath.row];
        cell.primaryLabel.text = [data objectForKey:@"team_name"];
        cell.secondaryLabel.text = [data objectForKey:@"description"];

        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        NSDate *theDate = [formatter dateFromString:[data objectForKey:@"first_date"]];
        [formatter release], formatter = nil;

        NSDateFormatter *df = [[NSDateFormatter alloc] init];

        [df setDateFormat:@"dd MMM yyyy HH:mm"];
        NSString *date = [NSString stringWithFormat:@"%@", [df stringFromDate:theDate]];

        cell.thirdLabel.text = [NSString stringWithFormat:@"%@", date];

        [df release];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tw titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"My teams";
    } else {
        return @"All teams";
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewTeamViewController *viewTeamViewController = [[ViewTeamViewController alloc] init];

    if (indexPath.section == 0) {
        viewTeamViewController.data = [registrations objectAtIndex:indexPath.row];
        viewTeamViewController.isAttending = YES;
    } else {
        viewTeamViewController.isAttending = NO;
        viewTeamViewController.data = [upcomingEvents objectAtIndex:indexPath.row];
    }

    [self.navigationController pushViewController:viewTeamViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (void)loadEventsFromLogin
{
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];

    ASIHTTPRequest *requestUserRegistrations = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kUserRegistrations, [preferences valueForKey:@"serverurl"]]]];
    [requestUserRegistrations setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    [requestUserRegistrations startSynchronous];

    NSError *error = [requestUserRegistrations error];
//NSLog(@"return string %@", [requestUserRegistrations responseString]);
//NSLog(@"error code %d", [requestUserRegistrations responseStatusCode]);
    if (!error) {
        if ([requestUserRegistrations responseStatusCode] == 200) {
            NSData *jsonData = [requestUserRegistrations responseData];
            NSDictionary *jsonRegistrations = [jsonData objectFromJSONData];

            NSLog(@"user registrations %@", jsonRegistrations);
            self.registrations = [jsonRegistrations objectForKey:@"data"];
        }
    }

    //NSLog(@"url %@", [NSURL URLWithString:[NSString stringWithFormat:kAllRegistrations, [preferences valueForKey:@"serverurl"]]]);
    ASIHTTPRequest *requestAllRegistrations = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kAllRegistrations, [preferences valueForKey:@"serverurl"]]]];
    [requestAllRegistrations setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    [requestAllRegistrations startSynchronous];

    error = [requestAllRegistrations error];

    if (!error) {
        if ([requestAllRegistrations responseStatusCode] == 200) {
            NSData *jsonData = [requestAllRegistrations responseData];
            NSDictionary *jsonRegistrations = [jsonData objectFromJSONData];

            self.upcomingEvents = [jsonRegistrations objectForKey:@"data"];
        }
    }

    [self.tableView reloadData]; 

    //NSLog(@"all registrations %@", upcomingEvents);
}

@end
