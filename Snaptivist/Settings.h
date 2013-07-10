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
#import "Signup.h"
#import <Reachability.h>
#import <AmazonS3Client.h>
#import <AWSS3.h>
#import <AmazonEndpoints.h>


@interface Settings : UIViewController

@property (nonatomic,weak) IBOutlet UILabel *numberOfSignups;
@property (nonatomic,weak) IBOutlet UIButton *syncButton;
@property (nonatomic,weak) IBOutlet UIButton *noPhotoSync;
@property(nonatomic,weak) IBOutlet UILabel *errors;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) NSMutableArray *readyToSync;
@property NSInteger outstandingSync;
@property NSInteger nextToSync;
@property BOOL noPhoto;
@property BOOL syncDisabled;

@property (nonatomic,retain) NSArray *signups;
@property (nonatomic,retain) NSArray *events;
@property (nonatomic,weak) NSString *event;

@property (nonatomic, retain) IBOutlet UIPickerView *myPickerView;
@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;

- (IBAction)removeSettings:(id)sender;
- (IBAction)noPhotoSync:(id)sender;

-(void)deleteSignup:(Signup *)signup;
-(void)saveSignup:(Signup *)signup;
-(int)addToSet:(Signup *)signup;
-(void)removeFromSet:(int)signup;

-(void)disableSync;
-(void)enableSync;
-(void)loadSignups;


@property (nonatomic, retain) AmazonS3Client *s3;

@end
