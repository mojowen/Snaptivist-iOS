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

@interface SnaptivistTabs : UIViewController

@property (nonatomic, retain) Signup *signup;
@property (nonatomic, retain) NSArray *reps;

@property (nonatomic, retain) NSManagedObjectContext *context;

@property (nonatomic,retain) UIImage *activeImage;
@property (nonatomic,retain) UIImage *inactiveImage;

// View Tabs
@property (nonatomic,retain) UIViewController *photosViewController;
@property (nonatomic,retain) UIViewController *formViewController;
@property (nonatomic,retain) UIViewController *repsViewController;
@property (nonatomic,retain) UIViewController *finishedViewController;

@property (nonatomic,retain) UIViewController *activeView;

// View Buttons
@property (nonatomic,retain) IBOutlet UIButton *photosButton;
@property (nonatomic,retain) IBOutlet UIButton *formButton;
@property (nonatomic,retain) IBOutlet UIButton *repsButton;
@property (nonatomic,retain) IBOutlet UIButton *finishedButton;

@property (nonatomic,retain) UIButton *activeButton;

-(void)goToPhoto;
-(void)goToForm;
-(void)goToReps;
-(void)goToFinished;

-(IBAction)goToPhotoAction:(id)sender;
-(IBAction)goToFormAction:(id)sender;
-(IBAction)goToRepsAction:(id)sender;
-(IBAction)goToFinishedAction:(id)sender;

@end
