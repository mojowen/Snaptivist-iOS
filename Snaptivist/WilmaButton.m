//
//  WilmaButton.m
//  Snaptivist
//
//  Created by Noah Manger on 7/1/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "WilmaButton.h"

@implementation WilmaButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)awakeFromNib {
    self.font = [UIFont fontWithName: @"Wilma-Base" size:self.font.pointSize];
}

@end
