//
//  EventsViewController.h
//  ClubMaster
//
//  Created by Henrik Hansen on 22/01/12.
//

#import <UIKit/UIKit.h>

@interface EventsViewController : UIViewController <MBProgressHUDDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSMutableArray *events;

@property (nonatomic, retain) MBProgressHUD *HUD;

@end
