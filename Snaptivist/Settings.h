//
//  Settings.h
//  Snaptivist
//
//  Created by Scott Duncombe on 6/26/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <RestKit/RestKit.h>

@interface Settings : UIViewController

@property (nonatomic,retain) IBOutlet UILabel *numberOfSignups;
@property (nonatomic,retain) IBOutlet UIButton *syncButton;

@property (nonatomic, retain) NSManagedObjectContext *context;

@property (nonatomic,retain) NSArray *signups;

@end
