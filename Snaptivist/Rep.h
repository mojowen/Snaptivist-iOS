//
//  Rep.h
//  Snaptivist
//
//  Created by Scott Duncombe on 6/24/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Rep : NSManagedObject

@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * bioguide;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * twitter_screen_name;
@property (nonatomic, retain) NSString * state_name;
@property (nonatomic, retain) NSString * district;
@property (nonatomic, retain) NSString * chamber;

@end
