//
//  FirstViewController.h
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnaptivistTabs.h"

@interface PhotosViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic,retain) IBOutlet UIImageView *background;

@property (nonatomic, retain) IBOutlet UIButton *noPhoto;
@property (nonatomic, retain) IBOutlet UIButton *launchCamera;

@property (nonatomic, retain) IBOutlet UIButton *takePhoto;

@property (nonatomic, retain) IBOutlet UIButton *selectPhoto;
@property (nonatomic, retain) IBOutlet UIButton *reLaunchCamera;

@property (nonatomic,retain) IBOutlet UIImageView *camera;

@property (nonatomic,retain) IBOutlet UIButton *pic1;
@property (nonatomic,retain) IBOutlet UIButton *pic2;
@property (nonatomic,retain) IBOutlet UIButton *pic3;
@property (nonatomic,retain) IBOutlet UIButton *pic4;
@property (nonatomic,retain) IBOutlet UIButton *pic5;


- (IBAction)goToForm:(id)sender;
- (IBAction)launchCamera:(id)sender;
- (IBAction)relaunchCamera:(id)sender;
- (IBAction)takePhotos:(id)sender;

- (IBAction)selectPic1:(id)sender;
- (IBAction)selectPic2:(id)sender;
- (IBAction)selectPic3:(id)sender;
- (IBAction)selectPic4:(id)sender;
- (IBAction)selectPic5:(id)sender;

@end

