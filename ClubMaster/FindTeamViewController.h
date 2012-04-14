//
//  FindTeamViewController.h
//  ClubMaster
//
//  Created by Henrik Hansen on 25/01/12.
//

#import <UIKit/UIKit.h>

@interface FindTeamViewController : UIViewController <MBProgressHUDDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSArray *registrations;
@property (nonatomic, retain) NSArray *attendingRegistrations;

@property (nonatomic, retain) MBProgressHUD *HUD;

@end
