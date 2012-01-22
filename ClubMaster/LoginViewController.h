//
//  LoginViewController.h
//  ClubMaster
//
//  Created by Henrik Hansen on 15/01/12.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITextField *urlField;
@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;

- (IBAction)login:(id)sender;

@end
