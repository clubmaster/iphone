//
//  Utils.h
//  ClubMaster
//
//  Created by Henrik Hansen on 14/04/12.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (NSString *)timestamp2Caption:(int)timestamp;
+ (NSString *)stripTags:(NSString *)str;

@end
