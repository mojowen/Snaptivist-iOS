//
//  SecondViewController.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "FormViewController.h"

@interface FormViewController ()

@end

@implementation FormViewController

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
    [zip resignFirstResponder];

    self.errorMessage.hidden = NO;
    self.errorMessage.text = @"";

    if( [zip.text length] < 5 ) {
        self.errorMessage.text = [NSString stringWithFormat:@"you need to enter your zip code"];
    } else {

        header.text = @"Add a friend";
        
        zip.hidden = YES;
        [addFriends setTitle:@"Add" forState:UIControlStateNormal];
        
        yourFriends.hidden = NO;
        friends.hidden = NO;
        
        [friends resignFirstResponder];
        
        NSMutableString *thefriends = [signup.friends mutableCopy];
        
        if( thefriends != nil ) {
            
            [thefriends appendString:friends.text ];
            [thefriends appendString:@"," ];
            
            signup.friends = [thefriends copy];
            
            yourFriends.text = [yourFriends.text stringByAppendingString:friends.text ];
            yourFriends.text = [yourFriends.text stringByAppendingString:@" \n" ];
            
            friends.text = @"";
            
        } else {
            yourFriends.text = @"";
            signup.friends = @"";
        }
        NSLog(@"%@",thefriends);

    }

}

- (IBAction)nextStep:(id)sender {
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    self.errorMessage.hidden = NO;
    self.errorMessage.text = @"";

    if( [stage isEqualToString:@"first"] ) {
        [first_name resignFirstResponder];
        [last_name resignFirstResponder];
        
        if( [first_name.text length] == 0 ) {
            NSString *error = @"first name";
            [errors addObject:error];
        }
        if( [last_name.text length] == 0 ) {
            NSString *error = @"last name";
            [errors addObject:error];
        }
        
        if( [errors count] == 0 ) {
            signup.firstName = first_name.text;
            signup.lastName = last_name.text;
            
            first_name.hidden = YES;
            last_name.hidden = YES;
            
            email.hidden = NO;
            twitter.hidden = NO;
            
            stage = @"second";
        } else {
            self.errorMessage.hidden = NO;
            self.errorMessage.text = [NSString stringWithFormat:@"you need to enter your %@",
                                      [errors componentsJoinedByString:@" and "] ];
        }
    } else if( [stage isEqualToString:@"second"] ) {
        [email resignFirstResponder];
        [twitter resignFirstResponder];
        
        if( [email.text length] == 0 ) {
            NSString *error = @"email";
            [errors addObject:error];
        }
        
        if( [errors count] == 0 ) {

            signup.email = email.text;
            signup.twitter = twitter.text;
            
            email.hidden = YES;
            twitter.hidden = YES;

            zip.hidden = NO;
            addFriends.hidden = NO;

            [nextButton setTitle:@"Done" forState: UIControlStateNormal];

            stage = @"third";
        } else {
            self.errorMessage.hidden = NO;
            self.errorMessage.text = [NSString stringWithFormat:@"you need to enter your %@",
                                      [errors componentsJoinedByString:@" and "] ];
        }
    } else {
        [zip resignFirstResponder];
        
        if( [zip.text length] < 5 ) {
            NSString *error = @"zip code";
            [errors addObject:error];
        }

        if( [errors count] == 0 ) {
            signup.zip = zip.text;
            
            [friends resignFirstResponder];
            
            [signup.friends stringByAppendingString:friends.text ];
            [signup.friends stringByAppendingString:@"," ];
            

            NSError *error = nil;
            if ([context save:&error]) {
                NSLog(@"The signup save was successful!");
            } else {
                NSLog(@"The signup save wasn't successful: %@", [error userInfo]);
            }

            [[self tabController] goToReps];

        } else {
            self.errorMessage.hidden = NO;
            self.errorMessage.text = [NSString stringWithFormat:@"you need to enter your %@",
                                      [errors componentsJoinedByString:@" and "] ];
        }

    }


}

#pragma mark - Private methods
-(SnaptivistTabs *)tabController {
    return ((SnaptivistTabs *)(self.parentViewController));
}

@end
