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

@synthesize nextButton,context,stage,signup,header,first_name,last_name,email,twitter,zip,addFriends,friends,yourFriends;

- (void)viewDidLoad
{
    
    stage = @"first";
    SnaptivistTabs *parent = [self tabController];
    context = parent.context;
    signup = parent.signup;

    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addFriends:(id)sender {

    header.text = @"Add a friend";

    zip.hidden = YES;
    [addFriends setTitle:@"Add" forState:UIControlStateNormal];
    
    yourFriends.hidden = NO;
    friends.hidden = NO;

    [friends resignFirstResponder];

    if( ! [friends.text isEqualToString:@""] ) {

        signup.friends = [signup.friends stringByAppendingString:friends.text ];
        signup.friends = [signup.friends stringByAppendingString:@"," ];

        yourFriends.text = [yourFriends.text stringByAppendingString:friends.text ];
        yourFriends.text = [yourFriends.text stringByAppendingString:@"\n" ];
        
        friends.text = @"";
        
    } else {
        yourFriends.text = @"";
        signup.friends = @"";
    }
}

- (IBAction)nextStep:(id)sender {
    
    if( [stage isEqualToString:@"first"] ) {
        [first_name resignFirstResponder];
        [last_name resignFirstResponder];
        
        signup.firstName = first_name.text;
        signup.lastName = last_name.text;
        
        first_name.hidden = YES;
        last_name.hidden = YES;

        email.hidden = NO;
        twitter.hidden = NO;

        stage = @"second";
    } else if( [stage isEqualToString:@"second"] ) {
        [email resignFirstResponder];
        [twitter resignFirstResponder];
        
        signup.email = email.text;
        signup.twitter = twitter.text;
        
        email.hidden = YES;
        twitter.hidden = YES;

        zip.hidden = NO;
        addFriends.hidden = NO;

        [nextButton setTitle:@"Done" forState: UIControlStateNormal];

        stage = @"third";
    } else {
        [zip resignFirstResponder];
        signup.zip = zip.text;
        
        [friends resignFirstResponder];
        
        [signup.friends stringByAppendingString:friends.text ];
        [signup.friends stringByAppendingString:@"," ];
        

        NSError *error = nil;
        if ([context save:&error]) {
            NSLog(@"The save was successful!");
        } else {
            NSLog(@"The save wasn't successful: %@", [error userInfo]);
        }

        [[self tabController] setSelectedIndex:2];

    }
    
    
}

#pragma mark - Private methods
-(SnaptivistTabs *)tabController {
    return ((SnaptivistTabs *)(self.parentViewController));
}

@end
