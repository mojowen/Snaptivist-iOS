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

@property (nonatomic, weak) Signup *signup;
@property (nonatomic, weak) NSManagedObjectContext *context;
@property (nonatomic,weak) SnaptivistTabs *parent;
@property (nonatomic,weak) IBOutlet UILabel *disclaimer;

@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UIImageView *repImage0;
@property (nonatomic, weak) IBOutlet UIImageView *repImage1;
@property (nonatomic, weak) IBOutlet UIImageView *repImage2;
@property (nonatomic, weak) IBOutlet UIImageView *repImage3;
@property (nonatomic, weak) IBOutlet UIImageView *repImage4;
@property (nonatomic, weak) IBOutlet UIImageView *repImage5;
@property (nonatomic, weak) IBOutlet UIImageView *repImage6;

@property (nonatomic,weak) IBOutlet UILabel *message;
@property (nonatomic, weak) IBOutlet UILabel *repName0;
@property (nonatomic, weak) IBOutlet UILabel *repName1;
@property (nonatomic, weak) IBOutlet UILabel *repName2;
@property (nonatomic, weak) IBOutlet UILabel *repName3;
@property (nonatomic, weak) IBOutlet UILabel *repName4;
@property (nonatomic, weak) IBOutlet UILabel *repName5;
@property (nonatomic, weak) IBOutlet UILabel *repName6;

-(IBAction)noMessage:(id)sender;
-(IBAction)sendMessage:(id)sender;

@end
