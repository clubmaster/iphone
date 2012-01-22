//
//  LoginViewController.m
//  ClubMaster
//
//  Created by Henrik Hansen on 15/01/12.
//

#import "LoginViewController.h"
#import "ASIHTTPRequest.h"
#import "User.h"
#import "JSONKit.h"

@implementation LoginViewController

@synthesize urlField, usernameField, passwordField;

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
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.urlField = nil;
    self.usernameField = nil;
    self.passwordField = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)login:(id)sender
{
    NSLog(@"url %@", [NSString stringWithFormat:kLoginUrl, urlField.text]);

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

            NSLog(@"user %@", jsonUser);

            NSMutableDictionary *user = [[NSMutableDictionary alloc] init];
            [user setObject:[[jsonUser objectForKey:@"data"] valueForKey:@"member_number"] forKey:@"member_number"];

            [preferences setObject:user forKey:@"user"];
            [preferences synchronize];

            [user release];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"loadEventsFromLogin" object:nil];

            [self dismissModalViewControllerAnimated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Wrong username and or password", @"")
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
