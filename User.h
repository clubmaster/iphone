//
//  User.h
//  ClubMaster
//
//  Created by Henrik Hansen on 16/01/12.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, retain) NSString *membernumber;
@property (nonatomic, retain) NSString *firstname;
@property (nonatomic, retain) NSString *lastname;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, retain) NSString *birthday;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *street;
@property (nonatomic, retain) NSString *postalcode;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *email;

@end
