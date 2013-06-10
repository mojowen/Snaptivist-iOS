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

@synthesize first_signup,info,first_name,last_name;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)nextStep:(id)sender {
        
    [first_name resignFirstResponder];
    [last_name resignFirstResponder];

    info.text = [NSString stringWithFormat:@"%@ %@",first_name.text,last_name.text];
    
    self.first_signup.firstName = first_name.text;
    self.first_signup.lastName = last_name.text;
    
    NSError *error = nil;

    if( [first_signup.managedObjectContext save:&error]) {
        NSLog(@"Saved!!!!");
    } else{
        NSLog(@"The save wasn't successful: %@", error);
    }
}

@end
