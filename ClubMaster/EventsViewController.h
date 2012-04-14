//
//  EventsViewController.h
//  ClubMaster
//
//  Created by Henrik Hansen on 22/01/12.
//

#import <UIKit/UIKit.h>

@interface EventsViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSMutableArray *events;

@end
