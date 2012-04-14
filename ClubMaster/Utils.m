//
//  Utils.m
//  ClubMaster
//
//  Created by Henrik Hansen on 14/04/12.
//

#import "Utils.h"

@implementation Utils

+ (NSString *)timestamp2Caption:(int)timestamp
{
    NSMutableString *caption = [[[NSMutableString alloc] init] autorelease];

    int days = floor(timestamp / 86400);
    timestamp = timestamp % 86400;
    int weeks = floor(days / 7);
    days = days % 7;
    int hours = floor(timestamp / 3600);
    timestamp = timestamp % 3600;
    int mins = floor(timestamp / 60);
    timestamp = timestamp % 60;

    if (weeks) {
        if (weeks != 1) {
            [caption appendString:[NSString stringWithFormat:@"%d weeks ", weeks]];
        } else {
            [caption appendString:[NSString stringWithFormat:@"%d week ", weeks]];
        }
    }

    if (days) {
        if (days != 1) {
            [caption appendString:[NSString stringWithFormat:@"%d days ", days]];
        } else {
            [caption appendString:[NSString stringWithFormat:@"%d day ", days]];
        }
    }

    if (hours) {
        if (hours != 1) {
            [caption appendString:[NSString stringWithFormat:@"%d hours ", hours]];
        } else {
            [caption appendString:[NSString stringWithFormat:@"%d hour ", hours]];
        }
    }

    if (mins) {
        [caption appendString:[NSString stringWithFormat:@"%d min ", mins]];
    }

    if (timestamp) {
        [caption appendString:[NSString stringWithFormat:@"%d sec ", timestamp]];
    }

	return caption;
}

+ (NSString *)stripTags:(NSString *)str
{
    NSMutableString *ms = [NSMutableString stringWithCapacity:[str length]];
    
    NSScanner *scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:nil];
    NSString *s = nil;
    while (![scanner isAtEnd])
    {
        [scanner scanUpToString:@"<" intoString:&s];
        if (s != nil)
            [ms appendString:s];
        [scanner scanUpToString:@">" intoString:NULL];
        if (![scanner isAtEnd])
            [scanner setScanLocation:[scanner scanLocation]+1];
        s = nil;
    }
    
    return ms;
}

@end
