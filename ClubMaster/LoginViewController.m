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

@implementation LoginViewController

@synthesize tableView;

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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)login:(id)sender
{
    //NSLog(@"url %@", [NSString stringWithFormat:kLoginUrl, urlField.text]);

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

            //NSLog(@"user %@", jsonUser);

            [preferences setObject:[jsonUser objectForKey:@"data"] forKey:@"user"];
            [preferences synchronize];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"loadEventsFromLogin" object:nil];

            [self dismissModalViewControllerAnimated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Wrong username and or password", @"")
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server fail", @"")
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
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

        CGRect frame = CGRectMake(120, 12, 145, 30);

        UITextField *playerTextField = [[UITextField alloc] initWithFrame:frame];
        playerTextField.adjustsFontSizeToFitWidth = YES;
        playerTextField.textColor = [UIColor blackColor];
        playerTextField.placeholder = @"";
        playerTextField.keyboardType = UIKeyboardTypeDefault;
        
        if ([indexPath row] == 0 || [indexPath row] == 1) {
            playerTextField.returnKeyType = UIReturnKeyNext;
        } else {
            playerTextField.returnKeyType = UIReturnKeyDone;
            playerTextField.secureTextEntry = YES;
        }
        
        playerTextField.backgroundColor = [UIColor whiteColor];
        playerTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
        playerTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
        playerTextField.textAlignment = UITextAlignmentLeft;
        playerTextField.tag = indexPath.row;
        // && ![[preferences valueForKey:@"url"] length]
        if (indexPath.row == 0) {
            playerTextField.text = @"http://demo.clubmaster.dk";
        } else if (indexPath.row == 1) { // && [[preferences valueForKey:@"account"] length]
            playerTextField.text = @"10";
        } else if (indexPath.row == 2) {
            playerTextField.text = @"1234";
        }
        
        playerTextField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
        [playerTextField setEnabled: YES];
        
        [cell addSubview:playerTextField];
        
        [playerTextField release];
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

@end
