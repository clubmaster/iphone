//
//  FirstViewController.h
//  ClubMaster
//
//  Created by Henrik Hansen on 15/11/11.
//

#import <UIKit/UIKit.h>

@interface MyTrainingViewController : UIViewController <UITableViewDelegate, MBProgressHUDDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UILabel *email;
@property (nonatomic, retain) IBOutlet UIImageView *image;

@property (nonatomic, retain) NSMutableArray *registrations;

@property (nonatomic, retain) MBProgressHUD *HUD;

@end
