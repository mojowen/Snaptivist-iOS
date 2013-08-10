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

-(SignupCell *)initializeCellwithParent:(Settings *)addedParent andSignup:(Signup *)addedSignup{
    // These objects are reused with different signups - every time they are loaded into the colection view
    // they're given this method. They should reset the check the newly added signup to see what
    // their state should be
    

    action = @"";
    parent = addedParent;
    signup = addedSignup;

    [self clearState];
    [self.photo setImage:[signup loadPhoto] forState:UIControlStateNormal];

    self.label.text = [NSString stringWithFormat:@"%@",signup.firstName];
    
    if( signup.didError )
        [self setErrorState];
    if( signup.isSyncing )
        [self.activity startAnimating];
    if( signup.isSelected )
        [self select];

    return self;
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
            if( self.signup.isSelected )
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
            [self hideFromView];
            [parent deleteSignup:signup];
            [parent loadSignups];
        }
    }
    action = nil;
}
-(void)select{
    [self.photo setAlpha:0.6f];
    [self.label setAlpha:0.6f];
    [self setBackgroundColor:[UIColor redColor]];
}
-(void)unselect{
    [self.photo setAlpha:1.0f];
    [self.label setAlpha:1.0f];
    [self setBackgroundColor:[UIColor clearColor]];

}
-(void)setErrorState {
    self.state.text = @"!!";
    [self.state setTextColor:[UIColor redColor]];
    self.state.hidden = NO;
    self.signup.didError = YES;
    self.signup.isSyncing = NO;
    [self.activity stopAnimating];
    [self unselect];
}
-(void)clearState {
    self.photo.hidden = NO;
    self.label.hidden = NO;
    self.deleteButton.hidden = NO;
    self.state.text = nil;
    self.state.hidden = YES;

    if( ! self.signup.isSelected )
        [self unselect];
    if( ! self.signup.isSyncing )
        [self.activity stopAnimating];

}
-(void)setSyncState {
    [self.activity startAnimating];
    self.signup.isSyncing = YES;
    if( signup.isSelected )
        [self select];
}
-(void)setSelectedState {
    [self select];
    [parent addToSet:self.signup];
    self.signup.isSelected = YES;
}
-(void)removeSelectedState {
    [self.activity stopAnimating];
    [self unselect];
    [parent removeFromSet:self.signup];
    self.signup.isSelected = NO;
}
-(void)hideFromView {
    self.photo.hidden = YES;
    [self setBackgroundColor:[UIColor clearColor]];
    self.label.hidden = YES;
    [self.activity stopAnimating];
    self.deleteButton.hidden = YES;
    self.action = @"hidden";
}

@end

