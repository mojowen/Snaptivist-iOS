//
//  SecondViewController.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "SecondViewController.h"
#import "AppDelegate.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

@synthesize info,first_name,last_name;

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
        
    NSManagedObjectContext *context = [[self appDelegate] managedObjectContext];

    Signup *first_signup = [NSEntityDescription insertNewObjectForEntityForName:@"Signup" inManagedObjectContext:context];

    [first_name resignFirstResponder];
    [last_name resignFirstResponder];

    info.text = [NSString stringWithFormat:@"%@ %@",first_name.text,last_name.text];
    
    first_signup.firstName = first_name.text;
    first_signup.lastName = last_name.text;
    
    NSError *error = nil;
    if ([context save:&error]) {
        NSLog(@"The save was successful!");
    } else {
        NSLog(@"The save wasn't successful: %@", [error userInfo]);
    }
    
}

#pragma mark - Private methods
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
