//
//  TableCellEvent.m
//  ClubMaster
//
//  Created by Henrik Hansen on 19/01/12.
//

#import "TableCellDetail.h"

@implementation TableCellDetail

@synthesize primaryLabel, secondaryLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        primaryLabel = [[[UILabel alloc] init] autorelease];
        [primaryLabel setTextAlignment:UITextAlignmentLeft];
        [primaryLabel setFont:[UIFont systemFontOfSize:16]];
        [primaryLabel setBackgroundColor:[UIColor clearColor]];

        secondaryLabel = [[[UILabel alloc] init] autorelease];
        [secondaryLabel setTextAlignment:UITextAlignmentLeft];
        [secondaryLabel setFont:[UIFont systemFontOfSize:14]];
        [secondaryLabel setTextColor:[UIColor lightGrayColor]];
        [secondaryLabel setBackgroundColor:[UIColor clearColor]];

        [self.contentView addSubview:primaryLabel];
        [self.contentView addSubview:secondaryLabel];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    primaryLabel.frame = CGRectMake(10.0, 10.0, 100.0, 25);
    secondaryLabel.frame = CGRectMake(105.0, 10.0, 190.0, 25);
}

- (void)dealloc
{
    [primaryLabel release];
    [secondaryLabel release];

    [super dealloc];
}

@end