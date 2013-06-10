//
//  SecondViewController.h
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Signup.h"

@interface SecondViewController : UIViewController

@property(nonatomic, retain) Signup *first_signup;

@property (nonatomic, retain) IBOutlet UITextField  *first_name;
@property (nonatomic, retain) IBOutlet UITextField  *last_name;

@property (nonatomic, retain) IBOutlet UITextView *info;

-(IBAction)nextStep:(id)sender;

@end
