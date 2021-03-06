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

@property (nonatomic, strong) Signup *signup;

@property (nonatomic, strong) NSManagedObjectContext *context;

@property (nonatomic,retain) UIImage *activeImage;
@property (nonatomic,retain) UIImage *inactiveImage;

// View Tabs
@property (nonatomic,weak) UIViewController *photosViewController;
@property (nonatomic,weak) UIViewController *formViewController;
@property (nonatomic,weak) UIViewController *repsViewController;
@property (nonatomic,weak) UIViewController *finishedViewController;

@property (nonatomic,retain) UIViewController *activeView;
@property (nonatomic,retain) IBOutlet UIImageView *allyLogo;


// View Buttons
@property (nonatomic,retain) IBOutlet UIButton *photosButton;
@property (nonatomic,retain) IBOutlet UIButton *formButton;
@property (nonatomic,retain) IBOutlet UIButton *repsButton;
@property (nonatomic,retain) IBOutlet UIButton *finishedButton;

@property (nonatomic,retain) UIButton *activeButton;

- (IBAction)cancelButton:(id)sender;
-(void)goToPhoto;
-(void)goToForm;
-(void)goToReps;
-(void)goToFinished;
-(void)hideButtons;
-(void)showButtons;
-(void)startOver;
@end
