//
//  EventsViewController.m
//  ClubMaster
//
//  Created by Henrik Hansen on 22/01/12.
//

#import "EventsViewController.h"
#import "FindEventViewController.h"
#import "EventTableViewCell.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "ISO8601DateFormatter.h"

#import <EventKit/EventKit.h>

@interface EventsViewController ()
- (void)find;
- (void)unattend:(UIButton *)sender;
- (void)addToCalendar:(UITapGestureRecognizer *)sender;
@end

@implementation EventsViewController

@synthesize tableView;
@synthesize events;
@synthesize HUD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Events", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"events"];
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
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Find event", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(find)] autorelease];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.tableView = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];    
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"Loading events", @"");
    [HUD showWhileExecuting:@selector(tasksToDoWhileShowingHUD) onTarget:self withObject:nil animated:YES];
}

- (void)tasksToDoWhileShowingHUD
{
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];

    ASIHTTPRequest *requestUserRegistrations = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kUserEvents, [preferences valueForKey:@"serverurl"]]]];
    [requestUserRegistrations setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    [requestUserRegistrations startSynchronous];

    NSError *error = [requestUserRegistrations error];
    //NSLog(@"return string %@", [requestUserRegistrations responseString]);
    //NSLog(@"error code %d", [requestUserRegistrations responseStatusCode]);
    if (!error) {
        if ([requestUserRegistrations responseStatusCode] == 200) {
            NSData *jsonData = [requestUserRegistrations responseData];
            NSDictionary *jsonRegistrations = [jsonData objectFromJSONData];
            //NSLog(@"events %@", jsonRegistrations);

            self.events = [[[NSMutableArray alloc] initWithArray:[jsonRegistrations objectForKey:@"data"]] autorelease];
        }
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [HUD removeFromSuperview];
    [HUD release];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", [events count]];
        [self.tableView reloadData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tw numberOfRowsInSection:(NSInteger)section
{
    return [events count];
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"EventTableViewCell" owner:nil options:nil];

        for (UIView *view in views) {
            if([view isKindOfClass:[UITableViewCell class]]) {
                cell = (EventTableViewCell *)view;
            }
        }
    }

    NSDictionary *data = [events objectAtIndex:indexPath.row];
    //NSLog(@"date %@", data);

    cell.attendButton.hidden = YES;
    cell.unattendButton.hidden = NO;

    cell.attendButton.tag = indexPath.row;

    [cell.unattendButton addTarget:self action:@selector(unattend:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];

    cell.desc.text = [Utils stripTags:[data objectForKey:@"description"]];
    cell.desc.contentInset = UIEdgeInsetsMake(-4,-8,0,0);

    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    NSDate *startDate = [formatter dateFromString:[data objectForKey:@"start_date"]];
    NSDate *stopDate = [formatter dateFromString:[data objectForKey:@"stop_date"]];
    [formatter release], formatter = nil;

    cell.duration.text = [Utils timestamp2Caption:([stopDate timeIntervalSince1970]-[startDate timeIntervalSince1970])];

    NSDateFormatter *df = [[NSDateFormatter alloc] init];

    [df setDateFormat:@"HH:mm"];

    cell.time.text = [NSString stringWithFormat:@"%@", [df stringFromDate:startDate]];

    [df setDateFormat:@"MMM dd"];

    cell.date.text = [NSString stringWithFormat:@"%@", [df stringFromDate:startDate]];

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

    [df release];

    return cell;
}

- (NSString *)tableView:(UITableView *)tw titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Events", @"");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)find
{
    FindEventViewController *findEventViewController = [[FindEventViewController alloc] init];
    findEventViewController.attendingEvents = events;
    [self.navigationController pushViewController:findEventViewController animated:YES];
    [findEventViewController release];
}

- (void)unattend:(UIButton *)sender
{
    //NSLog(@"unattend index %d", sender.tag);

    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];

    NSDictionary *data = [events objectAtIndex:sender.tag];

    ASIFormDataRequest *requestUnattend = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kUnattendEvent, [preferences valueForKey:@"serverurl"], [data objectForKey:@"id"]]]];
    [requestUnattend setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    [requestUnattend startSynchronous];

    NSError *error = [requestUnattend error];
    //NSLog(@"status code %d", [requestUnattend responseStatusCode]);
    //NSLog(@"return string %@", [requestUnattend responseString]);

    if (!error) {
        if ([requestUnattend responseStatusCode] == 200) {
            [events removeObjectAtIndex:sender.tag];

            NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];

            NSArray *indexPaths = [[[NSArray alloc] initWithObjects:indexPath, nil] autorelease];

            [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];

            [tableView reloadData];

            self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", [events count]];
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

    NSDictionary *data = [events objectAtIndex:indexPath.row];

    EKEventStore *eventStore = [[[EKEventStore alloc] init] autorelease];

    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.title = [data objectForKey:@"team_name"];

    ISO8601DateFormatter *formatter = [[[ISO8601DateFormatter alloc] init] autorelease];
    event.startDate = [formatter dateFromString:[data objectForKey:@"start_date"]];
    event.endDate = [formatter dateFromString:[data objectForKey:@"stop_date"]];

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

- (void)dealloc
{
    [events release];

    [super dealloc];
}

@end
