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

@property (retain, nonatomic) IBOutlet UILabel *label;
@property (retain, nonatomic) IBOutlet UILabel *state;
@property (retain, nonatomic) IBOutlet UIButton *photo;
@property (nonatomic) int readyPosition;
@property (retain,nonatomic) Signup *signup;
@property (retain,nonatomic) NSString *action;
@property (weak,nonatomic) Settings *parent;

-(void)setSyncState;
-(void)setErrorState;
-(void)clearState;

@end