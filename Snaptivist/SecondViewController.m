//
//  SecondViewController.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

@synthesize first_signup,info,name,email;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.first_signup = [[Signup alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)goToThird:(id)sender {
//    [((UITabBarController *)(self.parentViewController)) setSelectedIndex:2];
    [name resignFirstResponder];
    [email resignFirstResponder];

    info.text = [NSString stringWithFormat:@"%@ %@",name.text,email.text];
    // Ok so have got a method that needs to advanced 
}

@end
