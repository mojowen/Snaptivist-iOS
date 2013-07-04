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

@interface Settings : UIViewController

@property (nonatomic,retain) IBOutlet UILabel *numberOfSignups;
@property (nonatomic,retain) IBOutlet UIButton *syncButton;
@property(nonatomic,retain) IBOutlet UILabel *eventLabel;

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic,retain) RKObjectManager *objectManager;

@property (nonatomic,retain) NSArray *signups;
@property (nonatomic,retain) NSArray *events;
@property (nonatomic,retain) NSString *event;

@property (nonatomic, retain) IBOutlet UIPickerView *myPickerView;
@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;


-(void)deleteSignup:(Signup *)signup;
-(void)saveSignup:(Signup *)signup;

@end
