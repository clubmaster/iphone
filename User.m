//
//  User.m
//  ClubMaster
//
//  Created by Henrik Hansen on 16/01/12.
//

#import "User.h"

@implementation User

@synthesize membernumber, firstname, lastname, birthday, city, email, phone, state, gender, status, street, country, postalcode;


- (void)dealloc
{
    [membernumber release];
	[firstname release];
	[lastname release];
	[birthday release];
	[city release];
	[email release];
    [phone release];
    [state release];
    [gender release];
    [status release];
    [street release];
    [country release];
    [postalcode release];

	[super dealloc];
}



@end
