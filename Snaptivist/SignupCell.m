//
//  signupCell.m
//  Snaptivist
//
//  Created by Scott Duncombe on 7/4/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "SignupCell.h"


@implementation SignupCell

@synthesize parent,signup,action,readyPosition,activity;

-(void)viewDidLoad {
    parent = ((Settings *)[self superview]);
}

-(IBAction)delete:(id)sender {
    UIAlertView *myAlertView;
    
    if( parent.outstandingSync < 1 ) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:usLocale];
        
        NSString *title = [NSString stringWithFormat:@"Delete %@",signup.firstName];
        NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete %@ - from %@",signup.firstName,[dateFormatter stringFromDate:signup.photo_date]];
        
        action = @"Delete";
        
        myAlertView = [[UIAlertView alloc] initWithTitle:title
                                                 message: message
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Delete", nil];
    } else {
        myAlertView = [[UIAlertView alloc] initWithTitle:@"Cool Your Jets"
                                                 message:@"Things are saving - wait till that's done"
                                                delegate:self
                                       cancelButtonTitle:@"Ok - I'll wait"
                                       otherButtonTitles:nil, nil];
    }
    [myAlertView show];
    
}
-(IBAction)save:(id)sender {
    if( ! parent.syncDisabled ) {
        UIAlertView *myAlertView;
        
        if( parent.outstandingSync < 1 ) {
            if( [self.action isEqualToString:@"selected"] )
                [self removeSelectedState];
            else
                [self setSelectedState];
        } else {
            myAlertView = [[UIAlertView alloc] initWithTitle:@"Cool Your Jets"
                                                     message:@"Things are saving - wait till that's done"
                                                    delegate:self
                                           cancelButtonTitle:@"Ok - I'll wait"
                                           otherButtonTitles:nil, nil];
        }
        
        [myAlertView show];
    }
    
    
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if( buttonIndex == 1 ) {
        if( [action isEqualToString:@"Delete"]) {
            [self.activity startAnimating];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [parent deleteSignup:signup];
                [parent loadSignups];
            });
        }
    }
    action = nil;
}
-(void)setErrorState {
    self.state.text = @"!!";
    [self.state setTextColor:[UIColor redColor]];
    self.state.hidden = NO;
    self.signup.didError = YES;
}
-(void)clearState {
    self.state.text = nil;
    self.state.hidden = YES;
    [self setAlpha:1.0f];
    if( [self.action isEqualToString:@"selected"] )
        [self removeSelectedState];
}
-(void)setSyncState {
    NSLog(@"sync state set");
    [self.activity startAnimating];
    self.action = @"syncing";
}
-(void)setSelectedState {
    [self setAlpha:0.5f];
    [parent addToSet:self.signup];
    self.action = @"selected";
}
-(void)removeSelectedState {
    [self.activity stopAnimating];
    [self setAlpha:1.0f];
    [parent removeFromSet:self.signup];
    self.action = @"";
}

@end

