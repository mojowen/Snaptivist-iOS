//
//  UICustomLabel.m
//  Snaptivist
//
//  Created by Noah Manger on 6/25/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "UICustomLabel.h"

@implementation UICustomLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;


}

// Setting custom font for UICustomLabel
- (void)awakeFromNib {
    self.font = [UIFont fontWithName: @"Wilma-Base" size:self.font.pointSize];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



@end
