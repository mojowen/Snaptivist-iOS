//
//  signupCell.h
//  Snaptivist
//
//  Created by Scott Duncombe on 7/4/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Signup.h"
#import "Settings.h"

@interface SignupCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *state;
@property (weak, nonatomic) IBOutlet UIButton *photo;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (nonatomic) int readyPosition;
@property (weak,nonatomic) Signup *signup;
@property (weak,nonatomic) NSString *action;
@property (weak,nonatomic) Settings *parent;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

- (SignupCell *)initializeCellwithParent:(Settings *)parent andSignup:(Signup *)signup;
-(void)setSyncState;
-(void)setErrorState;
-(void)clearState;
-(void)hideFromView;
@end