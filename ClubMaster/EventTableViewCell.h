//
//  EventTableViewCell.h
//  ClubMaster
//
//  Created by Henrik Hansen on 14/04/12.
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *date;
@property (nonatomic, retain) IBOutlet UILabel *time;
@property (nonatomic, retain) IBOutlet UILabel *duration;

@property (nonatomic, retain) IBOutlet UITextView *desc;

@property (nonatomic, retain) IBOutlet UIButton *attendButton;
@property (nonatomic, retain) IBOutlet UIButton *unattendButton;

@property (nonatomic, retain) IBOutlet UILabel *addToCalendarLabel;
@property (nonatomic, retain) IBOutlet UIImageView *addToCalendarImage;

@end
