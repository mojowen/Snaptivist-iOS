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

@property Signup *first_signup;

@property (nonatomic, retain) IBOutlet UITextField  *name;
@property (nonatomic, retain) IBOutlet UITextField  *email;

@property (nonatomic, retain) IBOutlet UITextView *info;

@end
