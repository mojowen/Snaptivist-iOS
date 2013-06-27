//
//  UICustomTextField.m
//  Snaptivist
//
//  Created by Noah Manger on 6/26/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "UICustomTextField.h"

@implementation UICustomTextField

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


//- (void)drawRect:(CGRect)rect
//{
//    CGRect frameRect = self.frame;
//    frameRect.size.height = 50;
//    self.frame = frameRect;
//}


- (void)awakeFromNib {
    self.font = [UIFont fontWithName: @"Wilma-Base" size:self.font.pointSize];
    
    self.borderStyle = UITextBorderStyleNone;
    [self setBackgroundColor: [UIColor whiteColor]];
    

    // Hack to add left padding
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

@end
