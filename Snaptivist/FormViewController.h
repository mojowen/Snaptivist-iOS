//
//  SecondViewController.h
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnaptivistTabs.h"

@interface FormViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *nextButton;
@property (nonatomic, weak) NSString *stage;
@property (nonatomic, weak) Signup *signup;
@property (nonatomic, weak) NSManagedObjectContext *context;
@property (nonatomic, weak) IBOutlet UILabel *header;
@property (nonatomic,weak) IBOutlet UIImageView *photo;
@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;


@property (nonatomic, weak) IBOutlet UITextField  *first_name;
@property (nonatomic, weak) IBOutlet UITextField  *last_name;
@property (nonatomic, weak) IBOutlet UITextField  *email;
@property (nonatomic, weak) IBOutlet UITextField  *twitter;
@property (nonatomic, weak) IBOutlet UITextField  *zip;
@property (nonatomic, weak) IBOutlet UIButton *addFriends;

// Add Friends
@property (nonatomic, weak) IBOutlet UITextField  *friends;
@property (nonatomic, weak) IBOutlet UITextView *yourFriends;


-(IBAction)nextStep:(id)sender;
-(IBAction)addFriends:(id)sender;

@end
