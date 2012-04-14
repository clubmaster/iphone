//
//  LoginViewController.m
//  ClubMaster
//
//  Created by Henrik Hansen on 15/01/12.
//

#import "LoginViewController.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "TableCellDetail.h"

@interface LoginViewController ()
- (void)tasksToDoWhileShowingHUD;
@end

@implementation LoginViewController

@synthesize tableView;
@synthesize HUD;

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)login:(id)sender
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];    
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"Logging in", @"");
    [HUD showWhileExecuting:@selector(tasksToDoWhileShowingHUD) onTarget:self withObject:nil animated:YES];
}

- (void)tasksToDoWhileShowingHUD
{
    @autoreleasepool {
        UITableViewCell *urlCell = (UITableViewCell *)[[tableView subviews] objectAtIndex:2];
        UITextField *urlField = (UITextField *)[[urlCell subviews] objectAtIndex:2];

        UITableViewCell *usernameCell = (UITableViewCell *)[[tableView subviews] objectAtIndex:1];
        UITextField *usernameField = (UITextField *)[[usernameCell subviews] objectAtIndex:2];

        UITableViewCell *passwordCell = (UITableViewCell *)[[tableView subviews] objectAtIndex:0];
        UITextField *passwordField = (UITextField *)[[passwordCell subviews] objectAtIndex:2];

        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kLoginUrl, urlField.text]]];
        [request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
        [request setUsername:usernameField.text];
        [request setPassword:passwordField.text];
        [request startSynchronous];

        NSError *error = [request error];

        if (!error) {
            if ([request responseStatusCode] == 200) {
                NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
                [preferences setObject:urlField.text forKey:@"serverurl"];
                [preferences setObject:usernameField.text forKey:@"username"];
                [preferences setObject:passwordField.text forKey:@"password"];

                NSData *jsonData = [request responseData];
                NSDictionary *jsonUser = [jsonData objectFromJSONData];

                //NSLog(@"%@", jsonUser);

                [preferences setObject:[[jsonUser objectForKey:@"data"] objectForKey:@"first_name"] forKey:@"first_name"];
                [preferences setObject:[[jsonUser objectForKey:@"data"] objectForKey:@"last_name"] forKey:@"last_name"];
                [preferences setObject:[[jsonUser objectForKey:@"data"] objectForKey:@"postal_code"] forKey:@"postal_code"];
                [preferences setObject:[[jsonUser objectForKey:@"data"] objectForKey:@"street"] forKey:@"street"];
                [preferences setObject:[[jsonUser objectForKey:@"data"] objectForKey:@"email_address"] forKey:@"email_address"];

                [preferences synchronize];
            } else {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Wrong username and or password", @"")
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                          otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                }];
            }
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server fail", @"")
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
            }];
        }
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [HUD removeFromSuperview];
    [HUD release];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadEventsFromLogin" object:nil];
        [self dismissModalViewControllerAnimated:YES];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tw numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];

        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(120, 12, 145, 30)];
        textField.adjustsFontSizeToFitWidth = YES;
        textField.textColor = [UIColor blackColor];
        textField.placeholder = @"";
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.delegate = self;
        textField.tag = indexPath.row;

        if ([indexPath row] == 0 || [indexPath row] == 1) {
            textField.returnKeyType = UIReturnKeyNext;
        } else {
            textField.returnKeyType = UIReturnKeyDone;
            textField.secureTextEntry = YES;
        }

        textField.backgroundColor = [UIColor whiteColor];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.textAlignment = UITextAlignmentLeft;
        textField.tag = indexPath.row;
        textField.clearButtonMode = UITextFieldViewModeNever;
        textField.enabled = YES;

        if (indexPath.row == 0) {
            textField.text = @"http://demo.clubmaster.dk";
        } else if (indexPath.row == 1) {
            textField.text = @"1";
        } else if (indexPath.row == 2) {
            textField.text = @"1234";
        }

        [cell addSubview:textField];
        [textField release];
    }

    if ([indexPath row] == 0) {
        cell.textLabel.text = NSLocalizedString(@"Server URL", @"");
    } else if ([indexPath row] == 1) {
        cell.textLabel.text = NSLocalizedString(@"Account", @"");
    } else {
        cell.textLabel.text = NSLocalizedString(@"Password", @"");
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y - 210.0, 
                                  tableView.frame.size.width, tableView.frame.size.height);
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y + 210.0, 
                                  tableView.frame.size.width, tableView.frame.size.height);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;

    if (nextTag == 3) {
        [textField resignFirstResponder];
        [self login:nil];
    } else {        
        UIResponder *nextResponder = [tableView.superview viewWithTag:nextTag];

        if (nextResponder) {
            [nextResponder becomeFirstResponder];
        } else {
            [textField resignFirstResponder];
        }
    }

    return NO;
}

@end
