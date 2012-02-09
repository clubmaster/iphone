//
//  FirstViewController.m
//  ClubMaster
//
//  Created by Henrik Hansen on 15/11/11.
//

#import "MyTrainingViewController.h"
#import "ViewTeamViewController.h"
#import "TeamTableViewCell.h"
#import "FindTeamViewController.h"
#import "TableCellEventList.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "JSONKit.h"
#import "ISO8601DateFormatter.h"

#import <EventKit/EventKit.h>

@interface MyTrainingViewController ()
- (void)loadEventsFromLogin;
- (void)find;
- (void)unattend:(UIButton *)sender;
- (void)addToCalendar:(UITapGestureRecognizer *)sender;
@end

@implementation MyTrainingViewController

@synthesize tableView;
@synthesize registrations;
@synthesize name;
@synthesize email;
@synthesize image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"My training", @"");
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

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Find team", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(find)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.tableView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];

    self.name.text = [NSString stringWithFormat:@"%@ %@", [[preferences objectForKey:@"user"] objectForKey:@"first_name"], [[preferences objectForKey:@"user"] objectForKey:@"last_name"]];
    self.email.text = [[preferences objectForKey:@"user"] objectForKey:@"email_address"];

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tw numberOfRowsInSection:(NSInteger)section
{
    return [registrations count];
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    TeamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"TeamTableViewCell" owner:nil options:nil];

        for (UIView *view in views) {
            if([view isKindOfClass:[UITableViewCell class]]) {
                cell = (TeamTableViewCell *)view;
            }
        }
    }

    NSDictionary *data = [registrations objectAtIndex:indexPath.row];

    cell.attendButton.hidden = YES;
    cell.unattendButton.hidden = NO;
    
    cell.unattendButton.tag = indexPath.row;
    
    [cell.unattendButton addTarget:self action:@selector(unattend:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];

    cell.title.text = [data objectForKey:@"team_name"];

    NSArray *instructors = [data objectForKey:@"instructors"];

    if ([instructors count]) {
        cell.instructor.text = [NSString stringWithFormat:@"%@ %@", [[instructors objectAtIndex:0] objectForKey:@"first_name"], [[instructors objectAtIndex:0] objectForKey:@"last_name"]];
    } else {
        cell.instructor.text = @"";
    }

    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    NSDate *firstDate = [formatter dateFromString:[data objectForKey:@"first_date"]];
    NSDate *endDate = [formatter dateFromString:[data objectForKey:@"end_date"]];
    [formatter release], formatter = nil;

	unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
	NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags
                                                                   fromDate:firstDate
                                                                     toDate:endDate options:0];

    cell.duration.text = [NSString stringWithFormat:@"%02d:%02d", [components hour], [components minute]];

    NSDateFormatter *df = [[NSDateFormatter alloc] init];

    [df setDateFormat:@"HH:mm"];

    cell.time.text = [NSString stringWithFormat:@"%@", [df stringFromDate:firstDate]];

    [df setDateFormat:@"MMM dd"];

    cell.date.text = [NSString stringWithFormat:@"%@", [df stringFromDate:firstDate]];

    [df release];

    cell.addToCalendarImage.userInteractionEnabled = YES;

    UITapGestureRecognizer *addToCalImageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addToCalendar:)];
    addToCalImageTap.cancelsTouchesInView = YES;
    [cell.addToCalendarImage addGestureRecognizer:addToCalImageTap];
    [addToCalImageTap release];

    cell.addToCalendarLabel.userInteractionEnabled = YES;

    UITapGestureRecognizer *addToCalLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addToCalendar:)];
    addToCalLabelTap.cancelsTouchesInView = YES;
    [cell.addToCalendarLabel addGestureRecognizer:addToCalLabelTap];
    [addToCalLabelTap release];

    return cell;
}

- (NSString *)tableView:(UITableView *)tw titleForHeaderInSection:(NSInteger)section
{
    return @"Sessions";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewTeamViewController *viewTeamViewController = [[ViewTeamViewController alloc] init];
    viewTeamViewController.data = [registrations objectAtIndex:indexPath.row];
    viewTeamViewController.isAttending = YES;
    [self.navigationController pushViewController:viewTeamViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
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

            //NSLog(@"user registrations %@", jsonRegistrations);
            self.registrations = [[NSMutableArray alloc] initWithArray:[jsonRegistrations objectForKey:@"data"]];

            self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", [registrations count]];
        }
    }

    [self.tableView reloadData]; 
}

- (void)find
{
    FindTeamViewController *findTeamViewController = [[FindTeamViewController alloc] init];
    findTeamViewController.attendingRegistrations = registrations;
    [self.navigationController pushViewController:findTeamViewController animated:YES];
}

- (void)unattend:(UIButton *)sender
{
    NSLog(@"unattend index %d", sender.tag);

    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];

    NSDictionary *data = [registrations objectAtIndex:sender.tag];

    ASIFormDataRequest *requestUnattend = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kUnattendTeam, [preferences valueForKey:@"serverurl"], [data objectForKey:@"id"]]]];
    [requestUnattend setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    [requestUnattend startSynchronous];

    NSError *error = [requestUnattend error];
    NSLog(@"status code %d", [requestUnattend responseStatusCode]);
    NSLog(@"return string %@", [requestUnattend responseString]);

    if (!error) {
        if ([requestUnattend responseStatusCode] == 200) {
            [registrations removeObjectAtIndex:sender.tag];

            NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];

            NSArray *indexPaths = [[[NSArray alloc] initWithObjects:indexPath, nil] autorelease];

            [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];

            [tableView reloadData];

            self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", [registrations count]];
        } else {
            NSData *jsonData = [requestUnattend responseData];
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

- (void)addToCalendar:(UITapGestureRecognizer *)sender
{
    NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)[[[sender view] superview] superview]];

    NSLog(@"add to cal tapped %d", indexPath.row);

    NSDictionary *data = [registrations objectAtIndex:indexPath.row];

    EKEventStore *eventStore = [[EKEventStore alloc] init];

    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.title = [data objectForKey:@"team_name"];

    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    event.startDate = [formatter dateFromString:[data objectForKey:@"first_date"]];
    event.endDate = [formatter dateFromString:[data objectForKey:@"end_date"]];

    [event setCalendar:[eventStore defaultCalendarForNewEvents]];

    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -15.0f]];

    NSError *eventError;
    [eventStore saveEvent:event span:EKSpanThisEvent error:&eventError]; 

    if (eventError) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                                        message:[eventError localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Event added to calendar", @"")
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

@end
