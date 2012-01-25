//
//  TeamTableViewCell.h
//  ClubMaster
//
//  Created by Henrik Hansen on 25/01/12.
//

#import <UIKit/UIKit.h>

@interface TeamTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *date;
@property (nonatomic, retain) IBOutlet UILabel *time;
@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *duration;
@property (nonatomic, retain) IBOutlet UILabel *instructor;

@end
