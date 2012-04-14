//
//  TeamTableViewCell.m
//  ClubMaster
//
//  Created by Henrik Hansen on 25/01/12.
//

#import "TeamTableViewCell.h"

@implementation TeamTableViewCell

@synthesize date;
@synthesize time;
@synthesize title;
@synthesize duration;
@synthesize instructor;
@synthesize attendButton;
@synthesize unattendButton;
@synthesize addToCalendarLabel;
@synthesize addToCalendarImage;

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
    [title release];
    [duration release];
    [instructor release];
    [attendButton release];
    [unattendButton release];
    [addToCalendarImage release];
    [addToCalendarLabel release];
    
    [super dealloc];
}

@end
