//
//  FirstViewController.h
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnaptivistTabs.h"
#import <AVFoundation/AVFoundation.h>

@interface PhotosViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic,weak) IBOutlet UIImageView *background;

@property (nonatomic, weak) IBOutlet UIButton *noPhoto;
@property (nonatomic, weak) IBOutlet UIButton *launchCamera;

@property (nonatomic, weak) IBOutlet UIButton *takePhoto;
@property( nonatomic, weak) IBOutlet UIButton *switchCamera;

@property (nonatomic, weak) IBOutlet UIButton *selectPhoto;
@property (nonatomic, weak) IBOutlet UIButton *reLaunchCamera;

@property (nonatomic,weak) IBOutlet UIImageView *camera;
@property (nonatomic) IBOutlet UIView *previewView;

@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) BOOL isUsingFrontFacingCamera;
@property (nonatomic) CGFloat effectiveScale;
@property (nonatomic) UIView *flashView;

@property (weak, nonatomic) IBOutlet UIImageView *filmStrip;
@property (nonatomic,weak) IBOutlet UIButton *pic1;
@property (nonatomic,weak) IBOutlet UIButton *pic2;
@property (nonatomic,weak) IBOutlet UIButton *pic3;
@property (nonatomic,weak) IBOutlet UIButton *pic4;
@property (nonatomic,weak) IBOutlet UIButton *pic5;

@property (nonatomic,retain) NSArray *savedPhotos;
@property (nonatomic) int photoNumber;

- (IBAction)goToForm:(id)sender;
- (IBAction)launchCamera:(id)sender;
- (IBAction)takePhotos:(id)sender;

- (IBAction)relaunchCamera:(id)sender;
- (IBAction)setPhoto:(id)sender;

- (IBAction)selectPic1:(id)sender;
- (IBAction)selectPic2:(id)sender;
- (IBAction)selectPic3:(id)sender;
- (IBAction)selectPic4:(id)sender;
- (IBAction)selectPic5:(id)sender;

@end

