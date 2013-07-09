//
//  signupCell.m
//  Snaptivist
//
//  Created by Scott Duncombe on 7/4/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "SignupCell.h"


@implementation SignupCell

@synthesize parent,signup,action,readyPosition;

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
            if( [self.action isEqualToString:@"selected"] ) {
                [self removeSelectedState];
            } else {
                [self setSelectedState];
            }
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
            [parent deleteSignup:signup];
            [parent loadSignups];
        } else if ( [action isEqualToString:@"Sync"] ) {
            parent.outstandingSync = 1;
            parent.nextToSync = -1;
            [parent disableSync];
            [parent saveSignup:signup];
        }
    }
    action = nil;
}
-(void)setErrorState {
    self.state.text = @"!!";
    [self.state setTextColor:[UIColor redColor]];
    self.state.hidden = NO;
}
-(void)clearState {
    self.state.text = nil;
    self.state.hidden = YES;
    if( [self.action isEqualToString:@"selected"] )
        [self removeSelectedState];
}
-(void)setSyncState {
    self.state.text = @"sync";
    [self.state setTextColor:[UIColor whiteColor]];
    self.state.hidden = NO;
}
-(void)setSelectedState {
    [self setAlpha:0.5f];
    readyPosition = [parent addToSet:signup];
    self.action = @"selected";
}
-(void)removeSelectedState {
    [self setAlpha:1.0f];
    [parent removeFromSet:readyPosition];
    self.action = @"";
}

@end

