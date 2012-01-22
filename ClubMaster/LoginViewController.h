//
//  LoginViewController.h
//  ClubMaster
//
//  Created by Henrik Hansen on 15/01/12.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController  <UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (IBAction)login:(id)sender;

@end
