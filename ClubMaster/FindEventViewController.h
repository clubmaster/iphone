//
//  FindEventViewController.h
//  ClubMaster
//
//  Created by Henrik Hansen on 09/02/12.
//

#import <UIKit/UIKit.h>

@interface FindEventViewController : UIViewController <MBProgressHUDDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSArray *events;
@property (nonatomic, retain) NSArray *attendingEvents;

@property (nonatomic, retain) MBProgressHUD *HUD;

@end
