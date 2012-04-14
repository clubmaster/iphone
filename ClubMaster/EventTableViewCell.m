//
//  EventTableViewCell.m
//  ClubMaster
//
//  Created by Henrik Hansen on 14/04/12.
//

#import "EventTableViewCell.h"

@implementation EventTableViewCell

@synthesize date;
@synthesize time;
@synthesize duration;
@synthesize attendButton;
@synthesize unattendButton;
@synthesize addToCalendarLabel;
@synthesize addToCalendarImage;
@synthesize desc;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)dealloc
{
    [date release];
    [time release];
    [duration release];
    [attendButton release];
    [unattendButton release];
    [addToCalendarImage release];
    [addToCalendarLabel release];
    [desc release];

    [super dealloc];
}

@end
