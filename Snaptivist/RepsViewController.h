//
//  RepsViewController.h
//  Snaptivist
//
//  Created by Scott Duncombe on 6/24/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnaptivistTabs.h"
#import "Zip.h"
#import "Rep.h"

@interface RepsViewController : UIViewController

@property (nonatomic, retain) Signup *signup;
@property (nonatomic, retain) NSManagedObjectContext *context;

@property (nonatomic, retain) IBOutlet UIImageView *repImage0;
@property (nonatomic, retain) IBOutlet UIImageView *repImage1;
@property (nonatomic, retain) IBOutlet UIImageView *repImage2;

@property (nonatomic, retain) IBOutlet UILabel *repName0;
@property (nonatomic, retain) IBOutlet UILabel *repName1;
@property (nonatomic, retain) IBOutlet UILabel *repName2;


@end
