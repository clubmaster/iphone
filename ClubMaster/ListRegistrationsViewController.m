//
//  FirstViewController.m
//  ClubMaster
//
//  Created by Henrik Hansen on 15/11/11.
//

#import "ListRegistrationsViewController.h"
#import "ViewEventViewController.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "TableCellEventList.h"

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

    self.title = NSLocalizedString(@"Teams", @"");
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadEventsFromLogin) name:@"loadEventsFromLogin" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:@"loadEventsFromLogin"];
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
        cell.thirdLabel.text = [data objectForKey:@"first_date"];        
    } else {
        NSDictionary *data = [upcomingEvents objectAtIndex:indexPath.row];
        cell.primaryLabel.text = [data objectForKey:@"team_name"];
        cell.secondaryLabel.text = [data objectForKey:@"description"];
        cell.thirdLabel.text = [data objectForKey:@"first_date"];
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
    ViewEventViewController *viewEventViewController = [[ViewEventViewController alloc] init];

    if (indexPath.section == 0) {
        viewEventViewController.data = [registrations objectAtIndex:indexPath.row];
        viewEventViewController.isAttending = YES;
    } else {
        viewEventViewController.isAttending = NO;
        viewEventViewController.data = [upcomingEvents objectAtIndex:indexPath.row];
    }

    [self.navigationController pushViewController:viewEventViewController animated:YES];
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
    
    //NSLog(@"all registrations %@", upcomingEvents);
}

@end
