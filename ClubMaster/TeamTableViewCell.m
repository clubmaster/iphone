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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
