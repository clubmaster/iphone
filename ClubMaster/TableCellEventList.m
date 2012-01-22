//
//  TableCellEvent.m
//  ClubMaster
//
//  Created by Henrik Hansen on 01/12/11.
//

#import "TableCellEventList.h"

@implementation TableCellEventList

@synthesize primaryLabel, secondaryLabel, thirdLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        primaryLabel = [[[UILabel alloc] init] autorelease];
        [primaryLabel setTextAlignment:UITextAlignmentLeft];
        [primaryLabel setFont:[UIFont systemFontOfSize:18]];
        [primaryLabel setBackgroundColor:[UIColor clearColor]];
        
        secondaryLabel = [[[UILabel alloc] init] autorelease];
        [secondaryLabel setTextAlignment:UITextAlignmentLeft];
        [secondaryLabel setFont:[UIFont systemFontOfSize:13]];
        [secondaryLabel setTextColor:[UIColor lightGrayColor]];
        [secondaryLabel setBackgroundColor:[UIColor clearColor]];
        
        thirdLabel = [[[UILabel alloc] init] autorelease];
        [thirdLabel setTextAlignment:UITextAlignmentLeft];
        [thirdLabel setFont:[UIFont systemFontOfSize:13]];
        [thirdLabel setTextColor:[UIColor lightGrayColor]];
        [thirdLabel setBackgroundColor:[UIColor clearColor]];
        
        [self.contentView addSubview:primaryLabel];
        [self.contentView addSubview:secondaryLabel];
        [self.contentView addSubview:thirdLabel];
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

    primaryLabel.frame = CGRectMake(10.0, 5.0, 270.0, 25);
    secondaryLabel.frame = CGRectMake(12.0, 27, 270.0, 15);
    thirdLabel.frame = CGRectMake(12.0, 42, 270.0, 15);
}

- (void)dealloc
{
    [primaryLabel release];
    [secondaryLabel release];
    [thirdLabel release];
    
    [super dealloc];
}

@end