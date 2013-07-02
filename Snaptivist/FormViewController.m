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
    [self.photo setImage: [UIImage imageWithData:signup.photo] ];
    [self.first_name becomeFirstResponder];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)addAndFinish:(id)sender {
    [friends resignFirstResponder];

    if( friends.text.length > 0 && [self NSStringIsValidEmail:friends.text] )
        [self.addFriends sendActionsForControlEvents: UIControlEventTouchUpInside];
    
    [self.nextButton sendActionsForControlEvents: UIControlEventTouchUpInside];
}
- (IBAction)addFriends:(id)sender {

    [friends resignFirstResponder];
    
    if( [friends.text length] > 0 && [self NSStringIsValidEmail:friends.text] ) {
        NSMutableString *thefriends = [signup.friends mutableCopy];
        
        
        [thefriends appendString:friends.text ];
        [thefriends appendString:@"," ];
        
        signup.friends = [thefriends copy];
        
        yourFriends.text = [yourFriends.text stringByAppendingString:friends.text ];
        yourFriends.text = [yourFriends.text stringByAppendingString:@" \n" ];
        
        friends.text = @"";
        [self.addFriends setTitle:@"+Add Another" forState:UIControlStateNormal];
    } else {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Wait a sec!"
                                                              message:@"That's not an email address..."
                                                             delegate:nil
                                                    cancelButtonTitle:@"Sorry :("
                                                    otherButtonTitles: nil];
        [myAlertView show];
        friends.text = friends.text;
    }

}

- (IBAction)nextStep:(id)sender {
    NSMutableArray *errors = [[NSMutableArray alloc] init];

    [first_name resignFirstResponder];
    [last_name resignFirstResponder];
    [email resignFirstResponder];
    [twitter resignFirstResponder];
    [zip resignFirstResponder];

    if( [first_name.text length] == 0 ) {
        NSString *error = @"first name";
        [errors addObject:error];
    }
    if( [last_name.text length] == 0 ) {
        NSString *error = @"last name";
        [errors addObject:error];
    }
    if( [email.text length] < 1 || ! [self NSStringIsValidEmail:email.text] ) {
        NSString *error = @"email";
        [errors addObject:error];
    }
    if( [zip.text length] < 5 ) {
        NSString *error = @"zip code";
        [errors addObject:error];
    }

    
    if( [errors count] == 0 ) {
        signup.firstName = first_name.text;
        signup.lastName = last_name.text;
        signup.zip = zip.text;
        signup.email = email.text;
        signup.twitter = [twitter.text stringByReplacingOccurrencesOfString:@"@" withString:@""];

        NSError *error = nil;
        if ([context save:&error]) {
            NSLog(@"The signup save was successful!");
        } else {
            NSLog(@"The signup save wasn't successful: %@", [error userInfo]);
        }
        
        [[self tabController] goToReps];

    } else {
        NSString *lastError = [errors lastObject];
        [errors removeLastObject];
        NSString *joiner = @",";
        NSString *errorMessage;

        if( [errors count] == 1 )
            joiner = @"";

        if( [errors count] == 0 ) {
            errorMessage = [NSString stringWithFormat:@"you need to enter your %@", lastError];
        } else {
            NSString *allButLast = [NSString stringWithFormat:@"you need to enter your %@",
                                    [errors componentsJoinedByString:@", "] ];
            errorMessage = [NSString stringWithFormat:@"Hey %@%@ and %@",allButLast,joiner,lastError];
        }
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Wait a sec!"
                                                              message:errorMessage
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];
   
    }


}
-(void)viewDidAppear:(BOOL)animated {
    self.scrollView.frame = CGRectMake(0.0f,0.0f,1024.0f,764.0f);
    self.scrollView.contentSize = CGSizeMake(1024.0f, 1000.0f);
}
-(void)textFieldDidBeginEditing:(UITextField *)textField;
{
    if( self.zip == textField || self.email == textField || self.twitter == textField )
        [self.scrollView setContentOffset:CGPointMake(0.0f, textField.frame.origin.y - 200.0f) animated:YES];
    if( self.friends == textField )
        [self.scrollView setContentOffset:CGPointMake(0.0f, textField.frame.origin.y - 100.0f) animated:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField*)textField; {
    if ( self.first_name == textField) {
        [self.last_name becomeFirstResponder];
    }
    if ( self.last_name == textField ) {
        [self.zip becomeFirstResponder];
    }
    if (self.zip == textField ) {
        [self.email becomeFirstResponder];
    }
    if (self.email == textField) {
        [self.scrollView scrollRectToVisible:self.twitter.frame animated:YES];
        [self.twitter becomeFirstResponder];
    }
    if ( self.twitter == textField) {
        [self.nextButton sendActionsForControlEvents: UIControlEventTouchUpInside];
    }
    if( self.friends == textField ) {
        [self.addFriends sendActionsForControlEvents: UIControlEventTouchUpInside];
    }
    return YES;
}

#pragma mark - Private methods
-(SnaptivistTabs *)tabController {
    return ((SnaptivistTabs *)(self.parentViewController));
}
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
@end
