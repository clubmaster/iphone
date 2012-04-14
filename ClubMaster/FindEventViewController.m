//
//  FindEventViewController.m
//  ClubMaster
//
//  Created by Henrik Hansen on 09/02/12.
//

#import "FindEventViewController.h"
#import "EventTableViewCell.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "ISO8601DateFormatter.h"

@interface FindEventViewController ()
- (void)attend:(UIButton *)sender;
@end

@implementation FindEventViewController

@synthesize events;
@synthesize tableView;
@synthesize attendingEvents;
@synthesize HUD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Find event", @"");
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.tableView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];    
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"Finding events", @"");
    [HUD showWhileExecuting:@selector(tasksToDoWhileShowingHUD) onTarget:self withObject:nil animated:YES];
}

- (void)tasksToDoWhileShowingHUD
{
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];

    ASIHTTPRequest *requestEvents = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kAllEvents, [preferences valueForKey:@"serverurl"]]]];
    [requestEvents setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    [requestEvents startSynchronous];

    NSError *error = [requestEvents error];
    //NSLog(@"return string %@", [requestUserRegistrations responseString]);
    //NSLog(@"error code %d", [requestUserRegistrations responseStatusCode]);
    if (!error) {
        if ([requestEvents responseStatusCode] == 200) {
            NSData *jsonData = [requestEvents responseData];
            NSDictionary *jsonRegistrations = [jsonData objectFromJSONData];

            //NSLog(@"user registrations %@", jsonRegistrations);
            NSMutableArray *tmpEvents = [[NSMutableArray alloc] initWithArray:[jsonRegistrations objectForKey:@"data"]];

            for (int i = 0; i < [tmpEvents count]; i++) {
                NSDictionary *data = [tmpEvents objectAtIndex:i];
                if ([attendingEvents containsObject:data]) {
                    [tmpEvents removeObjectAtIndex:i];
                }
            }

            self.events = tmpEvents;
            [tmpEvents release];
        }
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [HUD removeFromSuperview];
    [HUD release];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
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

    cell.attendButton.hidden = NO;

    cell.attendButton.tag = indexPath.row;

    [cell.attendButton addTarget:self action:@selector(attend:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];

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

    //cell.addToCalendarLabel.hidden = YES;
    //cell.addToCalendarImage.hidden = YES;

    [df release];

    return cell;
}

- (NSString *)tableView:(UITableView *)tw titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"All events", @"");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (void)attend:(UIButton *)sender
{
    NSLog(@"attend index %d", sender.tag);

    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];

    NSDictionary *data = [events objectAtIndex:sender.tag];

    ASIFormDataRequest *requestAttend = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kAttendEvent, [preferences valueForKey:@"serverurl"], [data objectForKey:@"id"]]]];
    [requestAttend setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    [requestAttend startSynchronous];

    NSError *error = [requestAttend error];
    //NSLog(@"status code %d", [requestAttend responseStatusCode]);
    //NSLog(@"return string %@", [requestAttend responseString]);

    if (!error) {
        if ([requestAttend responseStatusCode] == 200) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attend Success", @"")
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];

            EventTableViewCell *cell = (EventTableViewCell *)[[sender superview] superview];
            cell.attendButton.hidden = YES;
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

- (void)dealloc
{
    [events release];
    [attendingEvents release];

    [super dealloc];
}

@end
