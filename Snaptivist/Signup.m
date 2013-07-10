//
//  Signup.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "Signup.h"


@implementation Signup

@dynamic firstName;
@dynamic lastName;
@dynamic email;
@dynamic twitter;
@dynamic zip;
@dynamic friends;
@dynamic reps;
@dynamic photo_date;
@dynamic sendTweet;
@dynamic photo;

@synthesize photo_path, didError,isSyncing;

-(id)init{
    self = [super init];
    self.isSyncing = NO;
    self.didError = NO;
    
    return self;
}

@end
