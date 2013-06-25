//
//  SnaptivistTabs.h
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Signup.h"

@interface SnaptivistTabs : UITabBarController

@property (nonatomic, retain) Signup *signup;
@property (nonatomic, retain) NSManagedObjectContext *context;

@end
