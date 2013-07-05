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

@interface Settings : UIViewController

@property (nonatomic,weak) IBOutlet UILabel *numberOfSignups;
@property (nonatomic,weak) IBOutlet UIButton *syncButton;
@property(nonatomic,weak) IBOutlet UILabel *errors;

@property (nonatomic, weak) NSManagedObjectContext *context;
@property (nonatomic,weak) RKObjectManager *objectManager;
@property NSInteger outstandingSync;
@property NSInteger nextToSync;

@property BOOL syncDisabled;

@property (nonatomic,retain) NSArray *signups;
@property (nonatomic,retain) NSArray *events;
@property (nonatomic,weak) NSString *event;

@property (nonatomic, retain) IBOutlet UIPickerView *myPickerView;
@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;

- (IBAction)removeSettings:(id)sender;

-(void)deleteSignup:(Signup *)signup;
-(void)saveSignup:(Signup *)signup;
-(void)disableSync;
-(void)enableSync;
-(void)loadSignups;

@end
