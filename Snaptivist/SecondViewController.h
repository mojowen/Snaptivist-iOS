//
//  SecondViewController.h
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnaptivistTabs.h"

@interface SecondViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) NSString *stage;
@property (nonatomic, retain) Signup *signup;
@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) IBOutlet UILabel *header;


// Stage 1
@property (nonatomic, retain) IBOutlet UITextField  *first_name;
@property (nonatomic, retain) IBOutlet UITextField  *last_name;

// Stage 2
@property (nonatomic, retain) IBOutlet UITextField  *email;
@property (nonatomic, retain) IBOutlet UITextField  *twitter;

// Stage 3
@property (nonatomic, retain) IBOutlet UITextField  *zip;
@property (nonatomic, retain) IBOutlet UIButton *addFriends;

// Add Friends
@property (nonatomic, retain) IBOutlet UITextField  *friends;
@property (nonatomic, retain) IBOutlet UITextView *yourFriends;


-(IBAction)nextStep:(id)sender;
-(IBAction)addFriends:(id)sender;

@end
