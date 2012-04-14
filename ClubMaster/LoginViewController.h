//
//  LoginViewController.h
//  ClubMaster
//
//  Created by Henrik Hansen on 15/01/12.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController  <UITableViewDelegate, UITextFieldDelegate, MBProgressHUDDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) MBProgressHUD *HUD;


- (IBAction)login:(id)sender;

@end
