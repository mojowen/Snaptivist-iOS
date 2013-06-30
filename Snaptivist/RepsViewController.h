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
@property (nonatomic, retain) IBOutlet UIImageView *repImage3;
@property (nonatomic, retain) IBOutlet UIImageView *repImage4;
@property (nonatomic, retain) IBOutlet UIImageView *repImage5;
@property (nonatomic, retain) IBOutlet UIImageView *repImage6;

@property (nonatomic, retain) IBOutlet UILabel *repName0;
@property (nonatomic, retain) IBOutlet UILabel *repName1;
@property (nonatomic, retain) IBOutlet UILabel *repName2;
@property (nonatomic, retain) IBOutlet UILabel *repName3;
@property (nonatomic, retain) IBOutlet UILabel *repName4;
@property (nonatomic, retain) IBOutlet UILabel *repName5;
@property (nonatomic, retain) IBOutlet UILabel *repName6;

-(IBAction)noMessage:(id)sender;
-(IBAction)sendMessage:(id)sender;

@end
